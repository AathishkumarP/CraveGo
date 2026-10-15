package com.cravego.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import org.json.JSONObject;

import com.cravego.dao.MenuDAO;
import com.cravego.dao.OrderDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Menu;
import com.cravego.model.Order;
import com.cravego.model.OrderItem;
import com.cravego.model.Restaurant;
import com.cravego.model.User;
import com.cravego.util.RazorpayUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final BigDecimal FREE_DELIVERY_LIMIT =
            new BigDecimal("499.00");

    private static final BigDecimal DELIVERY_FEE =
            new BigDecimal("40.00");

    private static final BigDecimal PLATFORM_FEE =
            new BigDecimal("5.00");

    private MenuDAO menuDAO;
    private RestaurantDAO restaurantDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);
        User user = getLoggedInUser(session);

        if (user == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        synchronized (session) {
            try {
                CheckoutData data = loadCheckoutData(session);

                if (data == null) {
                    response.sendRedirect(
                            request.getContextPath() + "/cart"
                    );
                    return;
                }

                ensureToken(session);
                showCheckout(request, response, data, null);

            } catch (IllegalArgumentException | ArithmeticException e) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Please check your cart and try again."
                );
            }
        }
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        boolean inlinePayment = isInlinePayment(request);

        HttpSession session = request.getSession(false);
        User user = getLoggedInUser(session);

        if (user == null) {
            if (inlinePayment) {
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

        synchronized (session) {
            Object expectedToken =
                    session.getAttribute("checkoutCsrfToken");

            if (!(expectedToken instanceof String)
                    || !expectedToken.equals(
                            request.getParameter("csrfToken")
                    )) {

                if (inlinePayment) {
                    sendJsonError(
                            response,
                            HttpServletResponse.SC_FORBIDDEN,
                            "Reopen checkout and try again."
                    );
                } else {
                    response.sendError(
                            HttpServletResponse.SC_FORBIDDEN,
                            "Reopen checkout and try again."
                    );
                }
                return;
            }

            CheckoutData data;

            try {
                data = loadCheckoutData(session);

            } catch (IllegalArgumentException | ArithmeticException e) {
                if (inlinePayment) {
                    sendJsonError(
                            response,
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Please check your cart and try again."
                    );
                } else {
                    response.sendError(
                            HttpServletResponse.SC_BAD_REQUEST,
                            "Please check your cart and try again."
                    );
                }
                return;
            }

            if (data == null) {
                if (inlinePayment) {
                    sendJsonError(
                            response,
                            HttpServletResponse.SC_CONFLICT,
                            "Your cart is empty. Please add food first."
                    );
                } else {
                    response.sendRedirect(
                            request.getContextPath() + "/cart"
                    );
                }
                return;
            }

            String selectedMode =
                    request.getParameter("paymentMode");

            boolean online =
                    "RAZORPAY".equals(selectedMode)
                    || "UPI".equals(selectedMode);

            if (!online && !"COD".equals(selectedMode)) {
                showCheckoutError(
                        request,
                        response,
                        data,
                        "Please select a valid payment method."
                );
                return;
            }

            // Inline requests are used only for online payment.
            if (inlinePayment && !online) {
                sendJsonError(
                        response,
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Select online payment to continue."
                );
                return;
            }

            if (online) {
                try {
                    RazorpayUtil.validateConfiguration();

                } catch (IllegalStateException e) {
                    showCheckoutError(
                            request,
                            response,
                            data,
                            "Online payment is currently unavailable. "
                            + "Please try again shortly."
                    );
                    return;
                }
            }

            /*
             * Reuse the existing pending online order when
             * its cart snapshot matches the current checkout.
             */
            Object pendingId =
                    session.getAttribute("pendingPaymentOrderId");

            if (pendingId instanceof Integer) {
                Order pending =
                        orderDAO.getOrderById((Integer) pendingId);

                if (pending == null) {
                    showCheckoutError(
                            request,
                            response,
                            data,
                            "Unable to check your previous payment order. "
                            + "Please try again."
                    );
                    return;
                }

                boolean sameCart = data.fingerprint.equals(
                        session.getAttribute(
                                "pendingPaymentFingerprint"
                        )
                );

                if (pending.getUserId() == user.getUserId()
                        && sameCart
                        && "RAZORPAY".equals(
                                pending.getPaymentMode()
                        )) {

                    if (pending.isPaid()) {
                        respondWithPaidOrder(
                                request,
                                response,
                                pending.getOrderId()
                        );
                        return;
                    }

                    if ("AWAITING_PAYMENT".equals(
                                pending.getStatus()
                            )
                            && "PENDING".equals(
                                pending.getPaymentStatus()
                            )) {

                        if (!online) {
                            showCheckoutError(
                                    request,
                                    response,
                                    data,
                                    "An online payment order already exists "
                                    + "for this cart. Continue that payment."
                            );
                            return;
                        }

                        respondWithPaymentOrder(
                                request,
                                response,
                                session,
                                pending.getOrderId()
                        );
                        return;
                    }
                }
            }

            Order order = new Order();

            order.setUserId(user.getUserId());
            order.setRestaurantId(
                    data.restaurant.getRestaurantId()
            );
            order.setOrderDate(LocalDateTime.now());
            order.setTotalAmount(
                    data.totalAmount.doubleValue()
            );
            order.setPaymentMode(
                    online ? "RAZORPAY" : "COD"
            );
            order.setPaymentStatus("PENDING");
            order.setStatus(
                    online ? "AWAITING_PAYMENT" : "PLACED"
            );

            List<OrderItem> orderItems =
                    createOrderItems(data);

            int orderId =
                    orderDAO.placeOrder(order, orderItems);

            if (orderId <= 0) {
                showCheckoutError(
                        request,
                        response,
                        data,
                        "We could not save your order. Please try again."
                );
                return;
            }

            order.setOrderId(orderId);

            if (online) {
                session.setAttribute(
                        "pendingPaymentOrderId",
                        orderId
                );

                session.setAttribute(
                        "pendingPaymentFingerprint",
                        data.fingerprint
                );

                session.setAttribute(
                        "pendingPaymentCart",
                        new LinkedHashMap<>(
                                data.cartSnapshot
                        )
                );

                session.setAttribute(
                        "pendingPaymentRestaurantId",
                        data.restaurant.getRestaurantId()
                );

                // Keep the cart until payment is confirmed.
                respondWithPaymentOrder(
                        request,
                        response,
                        session,
                        orderId
                );
                return;
            }

            // Cash on delivery order.
            session.removeAttribute("cart");
            session.removeAttribute("cartRestaurantId");

            session.setAttribute(
                    "lastPlacedOrder",
                    order
            );

            session.setAttribute(
                    "lastOrderedItems",
                    orderItems
            );

            session.setAttribute(
                    "lastRestaurant",
                    data.restaurant
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/order-success.jsp"
            );
        }
    }

    private boolean isInlinePayment(
            HttpServletRequest request) {

        return "true".equals(
                request.getParameter("inlinePayment")
        );
    }

    private void respondWithPaymentOrder(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            int orderId) throws IOException {

        if (isInlinePayment(request)) {
            Object token =
                    session.getAttribute("paymentCsrfToken");

            if (!(token instanceof String)) {
                token = UUID.randomUUID().toString();

                session.setAttribute(
                        "paymentCsrfToken",
                        token
                );
            }

            JSONObject result = new JSONObject();

            result.put("orderId", orderId);
            result.put("csrfToken", token);
            result.put("paid", false);

            writeJson(
                    response,
                    HttpServletResponse.SC_OK,
                    result
            );
            return;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/payment?orderId="
                + orderId
        );
    }

    private void respondWithPaidOrder(
            HttpServletRequest request,
            HttpServletResponse response,
            int orderId) throws IOException {

        String redirectUrl =
                request.getContextPath()
                + "/order-details?orderId="
                + orderId;

        if (isInlinePayment(request)) {
            JSONObject result = new JSONObject();

            result.put("orderId", orderId);
            result.put("paid", true);
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

    private void showCheckoutError(
            HttpServletRequest request,
            HttpServletResponse response,
            CheckoutData data,
            String message)
            throws ServletException, IOException {

        if (isInlinePayment(request)) {
            sendJsonError(
                    response,
                    HttpServletResponse.SC_CONFLICT,
                    message
            );
            return;
        }

        showCheckout(
                request,
                response,
                data,
                message
        );
    }

    private void sendJsonError(
            HttpServletResponse response,
            int status,
            String message) throws IOException {

        JSONObject result = new JSONObject();
        result.put("error", message);

        writeJson(response, status, result);
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

        response.getWriter().write(result.toString());
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

    private void ensureToken(HttpSession session) {

        if (!(session.getAttribute("checkoutCsrfToken")
                instanceof String)) {

            session.setAttribute(
                    "checkoutCsrfToken",
                    UUID.randomUUID().toString()
            );
        }
    }

    private CheckoutData loadCheckoutData(
            HttpSession session) {

        Object cartAttribute =
                session.getAttribute("cart");

        Object restaurantAttribute =
                session.getAttribute("cartRestaurantId");

        if (!(cartAttribute instanceof Map<?, ?>)
                || !(restaurantAttribute instanceof Integer)) {
            return null;
        }

        Map<?, ?> cart = (Map<?, ?>) cartAttribute;

        if (cart.isEmpty()) {
            return null;
        }

        int restaurantId =
                (Integer) restaurantAttribute;

        Restaurant restaurant =
                restaurantDAO.getRestaurantById(
                        restaurantId
                );

        if (restaurant == null
                || !restaurant.isActive()) {

            throw new IllegalArgumentException(
                    "This restaurant is currently unavailable."
            );
        }

        CheckoutData data = new CheckoutData();
        data.restaurant = restaurant;

        for (Map.Entry<?, ?> entry : cart.entrySet()) {

            if (!(entry.getKey() instanceof Integer)
                    || !(entry.getValue() instanceof Integer)) {

                throw new IllegalArgumentException(
                        "Invalid cart item."
                );
            }

            int menuId = (Integer) entry.getKey();
            int quantity = (Integer) entry.getValue();

            if (quantity < 1 || quantity > 10) {
                throw new IllegalArgumentException(
                        "Each item must have a quantity "
                        + "between 1 and 10."
                );
            }

            Menu menu = menuDAO.getMenuById(menuId);

            if (menu == null
                    || !menu.isAvailable()
                    || menu.getRestaurantId() != restaurantId) {

                throw new IllegalArgumentException(
                        "A cart item is unavailable. "
                        + "Please update your cart."
                );
            }

            if (!Double.isFinite(menu.getPrice())
                    || menu.getPrice() <= 0) {

                throw new IllegalArgumentException(
                        "A cart item has an invalid price."
                );
            }

            BigDecimal price =
                    BigDecimal.valueOf(menu.getPrice())
                            .setScale(
                                    2,
                                    RoundingMode.UNNECESSARY
                            );

            data.cartItems.put(menu, quantity);
            data.cartSnapshot.put(menuId, quantity);

            data.subtotal = data.subtotal.add(
                    price.multiply(
                            BigDecimal.valueOf(quantity)
                    )
            );

            data.totalQuantity += quantity;
        }

        data.deliveryFee =
                data.subtotal.compareTo(
                        FREE_DELIVERY_LIMIT
                ) >= 0
                ? BigDecimal.ZERO
                : DELIVERY_FEE;

        data.totalAmount = data.subtotal
                .add(data.deliveryFee)
                .add(PLATFORM_FEE)
                .setScale(
                        2,
                        RoundingMode.UNNECESSARY
                );

        data.fingerprint =
                restaurantId + "|"
                + new TreeMap<>(data.cartSnapshot) + "|"
                + data.totalAmount.toPlainString();

        return data;
    }

    private List<OrderItem> createOrderItems(
            CheckoutData data) {

        List<OrderItem> items = new ArrayList<>();

        for (Map.Entry<Menu, Integer> entry
                : data.cartItems.entrySet()) {

            Menu menu = entry.getKey();
            int quantity = entry.getValue();

            BigDecimal lineTotal =
                    BigDecimal.valueOf(menu.getPrice())
                            .multiply(
                                    BigDecimal.valueOf(quantity)
                            )
                            .setScale(
                                    2,
                                    RoundingMode.UNNECESSARY
                            );

            OrderItem item = new OrderItem();

            item.setMenuId(menu.getMenuId());
            item.setQuantity(quantity);
            item.setTotalAmount(
                    lineTotal.doubleValue()
            );

            items.add(item);
        }

        return items;
    }

    private void showCheckout(
            HttpServletRequest request,
            HttpServletResponse response,
            CheckoutData data,
            String errorMessage)
            throws ServletException, IOException {

        request.setAttribute(
                "restaurant",
                data.restaurant
        );

        request.setAttribute(
                "cartItems",
                data.cartItems
        );

        request.setAttribute(
                "subtotal",
                data.subtotal.doubleValue()
        );

        request.setAttribute(
                "deliveryFee",
                data.deliveryFee.doubleValue()
        );

        request.setAttribute(
                "platformFee",
                PLATFORM_FEE.doubleValue()
        );

        request.setAttribute(
                "totalAmount",
                data.totalAmount.doubleValue()
        );

        request.setAttribute(
                "totalQuantity",
                data.totalQuantity
        );

        if (errorMessage != null) {
            request.setAttribute(
                    "errorMessage",
                    errorMessage
            );
        }

        request.getRequestDispatcher("/checkout.jsp")
               .forward(request, response);
    }

    private static class CheckoutData {

        private Restaurant restaurant;

        private final Map<Menu, Integer> cartItems =
                new LinkedHashMap<>();

        private final Map<Integer, Integer> cartSnapshot =
                new LinkedHashMap<>();

        private BigDecimal subtotal = BigDecimal.ZERO;
        private BigDecimal deliveryFee;
        private BigDecimal totalAmount;

        private int totalQuantity;
        private String fingerprint;
    }
}