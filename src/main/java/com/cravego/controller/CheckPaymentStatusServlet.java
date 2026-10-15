package com.cravego.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import com.cravego.dao.OrderDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.model.Order;
import com.cravego.model.User;
import com.cravego.util.RazorpayUtil;
import com.razorpay.Payment;
import com.razorpay.RazorpayException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/check-payment-status")
public class CheckPaymentStatusServlet extends HttpServlet {

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
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser")
                        instanceof User)) {

            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object token = session.getAttribute("paymentCsrfToken");

        if (!(token instanceof String)
                || !token.equals(request.getParameter("csrfToken"))) {

            response.sendError(403, "Reopen the payment page.");
            return;
        }

        int orderId;

        try {
            orderId = Integer.parseInt(
                    request.getParameter("orderId")
            );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            response.sendError(400, "Invalid order ID.");
            return;
        }

        User user = (User) session.getAttribute("loggedInUser");
        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendError(404, "Order not found.");
            return;
        }

        if (order.getUserId() != user.getUserId()) {
            response.sendError(403, "You cannot access this payment.");
            return;
        }

        if (!"RAZORPAY".equals(order.getPaymentMode())) {
            response.sendError(409, "This is not a Razorpay order.");
            return;
        }

        if (order.isPaid()) {
            redirectToDetails(request, response, orderId);
            return;
        }

        String gatewayOrderId = order.getRazorpayOrderId();

        if (!"AWAITING_PAYMENT".equals(order.getStatus())
                || !"PENDING".equals(order.getPaymentStatus())
                || gatewayOrderId == null
                || gatewayOrderId.isBlank()) {

            response.sendError(409, "No pending gateway payment to check.");
            return;
        }

        try {
            List<Payment> payments =
                    RazorpayUtil.fetchOrderPayments(gatewayOrderId);

            for (Payment payment : payments) {
                String paymentStatus = payment.get("status");

                if (!"captured".equals(paymentStatus)) {
                    continue;
                }

                String paymentId = payment.get("id");

                boolean verified = RazorpayUtil.isCapturedPayment(
                        paymentId,
                        gatewayOrderId,
                        BigDecimal.valueOf(order.getTotalAmount())
                );

                if (!verified) {
                    showMessage(
                            request,
                            response,
                            order,
                            "A captured payment requires further review. "
                            + "Do not pay again."
                    );
                    return;
                }

                boolean confirmed = orderDAO.confirmOnlinePayment(
                        orderId,
                        gatewayOrderId,
                        paymentId
                );

                if (!confirmed) {
                    showMessage(
                            request,
                            response,
                            order,
                            "Payment was captured, but confirmation "
                            + "could not be saved. Do not pay again."
                    );
                    return;
                }

                session.setAttribute(
                        "orderMessage",
                        "Payment recovered successfully. "
                        + "Your order is confirmed."
                );

                session.setAttribute("orderMessageType", "success");

                /*
                 * Keep the cart here rather than risk clearing a newer
                 * cart. We will share cart-cleanup logic in a later step.
                 */
                redirectToDetails(request, response, orderId);
                return;
            }

            showMessage(
                    request,
                    response,
                    order,
                    "No captured payment is confirmed yet. "
                    + "If you completed payment, wait and check again."
            );

        } catch (RazorpayException | IllegalArgumentException
                | IllegalStateException e) {

            getServletContext().log(
                    "Payment status check failed for order " + orderId
            );

            showMessage(
                    request,
                    response,
                    order,
                    "Payment status could not be checked. "
                    + "Do not pay again if you completed payment."
            );
        }
    }

    private void redirectToDetails(
            HttpServletRequest request,
            HttpServletResponse response,
            int orderId) throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/order-details?orderId=" + orderId
        );
    }

    private void showMessage(
            HttpServletRequest request,
            HttpServletResponse response,
            Order order,
            String message)
            throws ServletException, IOException {

        request.setAttribute("paymentOrder", order);
        request.setAttribute("errorMessage", message);
        request.setAttribute("paymentReviewRequired", Boolean.TRUE);

        request.getRequestDispatcher("/payment.jsp")
               .forward(request, response);
    }
}