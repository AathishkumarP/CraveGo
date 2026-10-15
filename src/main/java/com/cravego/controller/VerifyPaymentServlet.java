package com.cravego.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

import com.cravego.dao.OrderDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.model.Order;
import com.cravego.model.User;
import com.cravego.util.RazorpayUtil;
import com.razorpay.RazorpayException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/verify-payment")
public class VerifyPaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser")
                        instanceof User)) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");

        Object expectedToken =
                session.getAttribute("paymentCsrfToken");

        if (!(expectedToken instanceof String)
                || !expectedToken.equals(
                        request.getParameter("csrfToken")
                )) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Your payment form session is invalid."
            );
            return;
        }

        int orderId;

        try {
            String value = request.getParameter("orderId");

            orderId = Integer.parseInt(
                    value == null ? "" : value.trim()
            );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID."
            );
            return;
        }

        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Order not found."
            );
            return;
        }

        if (order.getUserId() != user.getUserId()) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to access this payment."
            );
            return;
        }

        if (!"RAZORPAY".equals(order.getPaymentMode())) {
            response.sendError(
                    HttpServletResponse.SC_CONFLICT,
                    "This order does not use Razorpay."
            );
            return;
        }

        String savedGatewayOrderId = order.getRazorpayOrderId();

        String submittedGatewayOrderId =
                request.getParameter("razorpay_order_id");

        String paymentId =
                request.getParameter("razorpay_payment_id");

        String signature =
                request.getParameter("razorpay_signature");

        if (savedGatewayOrderId == null
                || !savedGatewayOrderId.equals(submittedGatewayOrderId)) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Payment order does not match the saved order."
            );
            return;
        }

        try {
            boolean signatureValid =
                    RazorpayUtil.verifyCheckoutSignature(
                            savedGatewayOrderId,
                            paymentId,
                            signature
                    );

            if (!signatureValid) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Payment signature verification failed."
                );
                return;
            }

            /*
             * A repeated confirmation must match the payment
             * already stored. Do not alter its delivery status.
             */
            if (order.isPaid()) {

                if (!paymentId.equals(order.getRazorpayPaymentId())) {
                    response.sendError(
                            HttpServletResponse.SC_CONFLICT,
                            "This order already has a different payment."
                    );
                    return;
                }

                completeSessionCheckout(session, orderId);
                redirectToDetails(request, response, orderId);
                return;
            }

            if (!"AWAITING_PAYMENT".equals(order.getStatus())
                    || !"PENDING".equals(order.getPaymentStatus())) {

                response.sendError(
                        HttpServletResponse.SC_CONFLICT,
                        "This order is not awaiting payment."
                );
                return;
            }

            boolean captured =
                    RazorpayUtil.isCapturedPayment(
                            paymentId,
                            savedGatewayOrderId,
                            BigDecimal.valueOf(order.getTotalAmount())
                    );

            if (!captured) {
                showPaymentMessage(
                        request,
                        response,
                        order,
                        "Payment capture is not yet confirmed. "
                        + "Do not pay again if your payment succeeded. "
                        + "Check your order status shortly."
                );
                return;
            }

            boolean confirmed = orderDAO.confirmOnlinePayment(
                    orderId,
                    savedGatewayOrderId,
                    paymentId
            );

            if (!confirmed) {
                showPaymentMessage(
                        request,
                        response,
                        order,
                        "Your payment was captured, but the order "
                        + "confirmation could not be saved. "
                        + "Do not pay again. Please check your order shortly."
                );
                return;
            }

            completeSessionCheckout(session, orderId);

            session.setAttribute(
                    "orderMessage",
                    "Payment verified successfully. "
                    + "Your order is confirmed."
            );

            session.setAttribute("orderMessageType", "success");

            redirectToDetails(request, response, orderId);

        } catch (RazorpayException e) {

            getServletContext().log(
                    "Razorpay verification could not complete "
                    + "for CraveGo order " + orderId
            );

            showPaymentMessage(
                    request,
                    response,
                    order,
                    "We could not check your payment with Razorpay. "
                    + "Do not pay again if it succeeded. "
                    + "Check your order status shortly."
            );

        } catch (IllegalArgumentException e) {

            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid payment response."
            );

        } catch (IllegalStateException e) {

            response.sendError(
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Payment verification is temporarily unavailable."
            );
        }
    }

    private void completeSessionCheckout(
            HttpSession session,
            int orderId) {

        synchronized (session) {

            Object pendingId =
                    session.getAttribute("pendingPaymentOrderId");

            if (!(pendingId instanceof Integer)
                    || ((Integer) pendingId).intValue() != orderId) {
                return;
            }

            Object savedCart =
                    session.getAttribute("pendingPaymentCart");

            Object currentCart = session.getAttribute("cart");

            Object savedRestaurant =
                    session.getAttribute("pendingPaymentRestaurantId");

            Object currentRestaurant =
                    session.getAttribute("cartRestaurantId");

            /*
             * Clear only the cart that belongs to this payment.
             * Keep any newer or edited cart.
             */
            if (savedCart instanceof Map<?, ?>
                    && savedCart.equals(currentCart)
                    && savedRestaurant != null
                    && savedRestaurant.equals(currentRestaurant)) {

                session.removeAttribute("cart");
                session.removeAttribute("cartRestaurantId");
            }

            session.removeAttribute("pendingPaymentOrderId");
            session.removeAttribute("pendingPaymentFingerprint");
            session.removeAttribute("pendingPaymentCart");
            session.removeAttribute("pendingPaymentRestaurantId");
            session.removeAttribute("unlinkedRazorpayOrder_" + orderId);
        }
    }

    private void redirectToDetails(
            HttpServletRequest request,
            HttpServletResponse response,
            int orderId) throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/order-details?orderId="
                + orderId
        );
    }

    private void showPaymentMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            Order order,
            String message)
            throws ServletException, IOException {

        request.setAttribute("paymentOrder", order);
        request.setAttribute("errorMessage", message);

        // Hide Pay and show Check Payment Status.
        request.setAttribute("paymentReviewRequired", Boolean.TRUE);

        request.setAttribute(
                "razorpayKeyId",
                RazorpayUtil.getKeyId()
        );

        request.getRequestDispatcher("/payment.jsp")
               .forward(request, response);
    }
    
}