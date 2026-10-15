package com.cravego.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.UUID;

import org.json.JSONObject;

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

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        prepareResponse(response);

        HttpSession session = request.getSession(false);
        User user = getLoggedInUser(session);

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        Order order = loadAuthorizedOrder(
                request,
                response,
                user
        );

        if (order == null) {
            return;
        }

        if (order.isPaid()) {
            respondWithPaidOrder(request, response, order);
            return;
        }

        if (!isPendingOnlineOrder(order)) {
            respondWithError(
                    request,
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    "This order is not awaiting online payment."
            );
            return;
        }

        synchronized (session) {
            ensurePaymentToken(session);
        }

        showPayment(request, response, order, null);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        prepareResponse(response);

        HttpSession session = request.getSession(false);
        User user = getLoggedInUser(session);

        if (user == null) {
            if (isInlinePayment(request)) {
                sendJsonError(
                        response,
                        HttpServletResponse.SC_UNAUTHORIZED,
                        "Your session expired. Please log in again."
                );
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/login"
                );
            }
            return;
        }

        /*
         * Serialize payment preparation within this session.
         * The saved gateway order is reused on subsequent requests.
         */
        synchronized (session) {
            Object expectedToken =
                    session.getAttribute("paymentCsrfToken");

            if (!(expectedToken instanceof String)
                    || !expectedToken.equals(
                            request.getParameter("csrfToken")
                    )) {

                respondWithError(
                        request,
                        response,
                        HttpServletResponse.SC_FORBIDDEN,
                        "Reopen checkout or the payment page and try again."
                );
                return;
            }

            Order order = loadAuthorizedOrder(
                    request,
                    response,
                    user
            );

            if (order == null) {
                return;
            }

            if (order.isPaid()) {
                respondWithPaidOrder(
                        request,
                        response,
                        order
                );
                return;
            }

            if (!isPendingOnlineOrder(order)) {
                respondWithError(
                        request,
                        response,
                        HttpServletResponse.SC_CONFLICT,
                        "This order is not awaiting online payment."
                );
                return;
            }

            try {
                RazorpayUtil.validateConfiguration();

                String gatewayOrderId =
                        order.getRazorpayOrderId();

                if (gatewayOrderId == null
                        || gatewayOrderId.isBlank()) {

                    String recoveryKey =
                            "unlinkedRazorpayOrder_"
                            + order.getOrderId();

                    Object recoveredId =
                            session.getAttribute(recoveryKey);

                    if (recoveredId instanceof String) {
                        gatewayOrderId =
                                (String) recoveredId;

                    } else {
                        com.razorpay.Order gatewayOrder =
                                RazorpayUtil.createGatewayOrder(
                                        order.getOrderId(),
                                        BigDecimal.valueOf(
                                                order.getTotalAmount()
                                        )
                                );

                        gatewayOrderId =
                                gatewayOrder.get("id");

                        if (gatewayOrderId == null
                                || !gatewayOrderId.startsWith(
                                        "order_"
                                )) {

                            throw new IllegalStateException(
                                    "Invalid gateway order response."
                            );
                        }

                        /*
                         * Keep this ID if database linking fails,
                         * so a retry can reuse the gateway order.
                         */
                        session.setAttribute(
                                recoveryKey,
                                gatewayOrderId
                        );
                    }

                    boolean attached =
                            orderDAO.attachRazorpayOrder(
                                    order.getOrderId(),
                                    user.getUserId(),
                                    gatewayOrderId
                            );

                    if (!attached) {
                        showPreparationError(
                                request,
                                response,
                                order,
                                "Unable to prepare your payment. "
                                + "Please try again shortly."
                        );
                        return;
                    }

                    session.removeAttribute(recoveryKey);
                }

                /*
                 * Reload the saved order before returning payment
                 * details. A webhook may have confirmed it meanwhile.
                 */
                Order savedOrder =
                        orderDAO.getOrderById(
                                order.getOrderId()
                        );

                if (savedOrder == null) {
                    showPreparationError(
                            request,
                            response,
                            order,
                            "Unable to reload your order. "
                            + "Please check My Orders."
                    );
                    return;
                }

                if (savedOrder.getUserId()
                        != user.getUserId()) {

                    respondWithError(
                            request,
                            response,
                            HttpServletResponse.SC_FORBIDDEN,
                            "You cannot access this payment."
                    );
                    return;
                }

                if (savedOrder.isPaid()) {
                    respondWithPaidOrder(
                            request,
                            response,
                            savedOrder
                    );
                    return;
                }

                if (!isPendingOnlineOrder(savedOrder)) {
                    respondWithError(
                            request,
                            response,
                            HttpServletResponse.SC_CONFLICT,
                            "This order is no longer awaiting payment."
                    );
                    return;
                }

                String savedGatewayOrderId =
                        savedOrder.getRazorpayOrderId();

                if (savedGatewayOrderId == null
                        || savedGatewayOrderId.isBlank()) {

                    showPreparationError(
                            request,
                            response,
                            savedOrder,
                            "Payment preparation could not be confirmed. "
                            + "Please try again shortly."
                    );
                    return;
                }

                if (isInlinePayment(request)) {
                    sendCheckoutConfiguration(
                            response,
                            session,
                            savedOrder,
                            user
                    );
                    return;
                }

                response.sendRedirect(
                        request.getContextPath()
                        + "/payment?orderId="
                        + savedOrder.getOrderId()
                );

            } catch (RazorpayException e) {
                getServletContext().log(
                        "Razorpay order preparation failed "
                        + "for CraveGo order "
                        + order.getOrderId()
                );

                showPreparationError(
                        request,
                        response,
                        order,
                        "The payment gateway could not be reached. "
                        + "Please try again shortly."
                );

            } catch (IllegalArgumentException
                    | IllegalStateException
                    | ArithmeticException e) {

                getServletContext().log(
                        "Payment configuration or amount error "
                        + "for CraveGo order "
                        + order.getOrderId()
                );

                showPreparationError(
                        request,
                        response,
                        order,
                        "Online payment is temporarily unavailable."
                );
            }
        }
    }

    private void sendCheckoutConfiguration(
            HttpServletResponse response,
            HttpSession session,
            Order order,
            User user) throws IOException {

        ensurePaymentToken(session);

        long amountPaise = RazorpayUtil.toPaise(
                BigDecimal.valueOf(
                        order.getTotalAmount()
                )
        );

        JSONObject result = new JSONObject();

        result.put("paid", false);
        result.put("orderId", order.getOrderId());
        result.put("key", RazorpayUtil.getKeyId());
        result.put(
                "gatewayOrderId",
                order.getRazorpayOrderId()
        );
        result.put("amount", amountPaise);
        result.put("currency", "INR");
        result.put(
                "csrfToken",
                session.getAttribute("paymentCsrfToken")
        );

        JSONObject prefill = new JSONObject();

        prefill.put(
                "name",
                safeString(user.getUsername())
        );
        prefill.put(
                "email",
                safeString(user.getEmail())
        );
        prefill.put(
                "contact",
                safeString(user.getPhone())
        );

        result.put("prefill", prefill);

        writeJson(
                response,
                HttpServletResponse.SC_OK,
                result
        );
    }

    private Order loadAuthorizedOrder(
            HttpServletRequest request,
            HttpServletResponse response,
            User user) throws IOException {

        int orderId;

        try {
            String value =
                    request.getParameter("orderId");

            orderId = Integer.parseInt(
                    value == null ? "" : value.trim()
            );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            respondWithError(
                    request,
                    response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID."
            );
            return null;
        }

        Order order =
                orderDAO.getOrderById(orderId);

        if (order == null) {
            respondWithError(
                    request,
                    response,
                    HttpServletResponse.SC_NOT_FOUND,
                    "Order not found."
            );
            return null;
        }

        if (order.getUserId() != user.getUserId()) {
            respondWithError(
                    request,
                    response,
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to pay for this order."
            );
            return null;
        }

        return order;
    }

    private void respondWithPaidOrder(
            HttpServletRequest request,
            HttpServletResponse response,
            Order order) throws IOException {

        String redirectUrl =
                request.getContextPath()
                + "/order-details?orderId="
                + order.getOrderId();

        if (isInlinePayment(request)) {
            JSONObject result = new JSONObject();

            result.put("paid", true);
            result.put("orderId", order.getOrderId());
            result.put("redirectUrl", redirectUrl);

            writeJson(
                    response,
                    HttpServletResponse.SC_OK,
                    result
            );
            return;
        }

        response.sendRedirect(redirectUrl);
    }

    private boolean isPendingOnlineOrder(Order order) {

        return "RAZORPAY".equals(
                    order.getPaymentMode()
                )
                && "PENDING".equals(
                    order.getPaymentStatus()
                )
                && "AWAITING_PAYMENT".equals(
                    order.getStatus()
                );
    }

    private boolean isInlinePayment(
            HttpServletRequest request) {

        return "true".equals(
                request.getParameter("inlinePayment")
        );
    }

    private User getLoggedInUser(HttpSession session) {

        if (session == null) {
            return null;
        }

        Object user =
                session.getAttribute("loggedInUser");

        return user instanceof User
                ? (User) user
                : null;
    }

    private void ensurePaymentToken(
            HttpSession session) {

        if (!(session.getAttribute("paymentCsrfToken")
                instanceof String)) {

            session.setAttribute(
                    "paymentCsrfToken",
                    UUID.randomUUID().toString()
            );
        }
    }

    private void showPreparationError(
            HttpServletRequest request,
            HttpServletResponse response,
            Order order,
            String message)
            throws ServletException, IOException {

        if (isInlinePayment(request)) {
            sendJsonError(
                    response,
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    message
            );
            return;
        }

        showPayment(
                request,
                response,
                order,
                message
        );
    }

    private void respondWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        if (isInlinePayment(request)) {
            sendJsonError(
                    response,
                    status,
                    message
            );
            return;
        }

        response.sendError(status, message);
    }

    private void sendJsonError(
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        JSONObject result = new JSONObject();
        result.put("error", message);

        writeJson(
                response,
                status,
                result
        );
    }

    private void writeJson(
            HttpServletResponse response,
            int status,
            JSONObject result) throws IOException {

        response.setStatus(status);
        response.setContentType(
                "application/json; charset=UTF-8"
        );
        response.setHeader("Cache-Control", "no-store");

        response.getWriter().write(
                result.toString()
        );
    }

    private String safeString(String value) {
        return value == null ? "" : value;
    }

    private void showPayment(
            HttpServletRequest request,
            HttpServletResponse response,
            Order order,
            String errorMessage)
            throws ServletException, IOException {

        request.setAttribute(
                "paymentOrder",
                order
        );

        try {
            request.setAttribute(
                    "razorpayKeyId",
                    RazorpayUtil.getKeyId()
            );

        } catch (IllegalStateException e) {
            errorMessage =
                    "Online payment is not configured.";
        }

        if (errorMessage != null) {
            request.setAttribute(
                    "errorMessage",
                    errorMessage
            );
        }

        request.getRequestDispatcher("/payment.jsp")
               .forward(request, response);
    }

    private void prepareResponse(
            HttpServletResponse response) {

        response.setContentType(
                "text/html; charset=UTF-8"
        );
        response.setHeader("Cache-Control", "no-store");
    }
}