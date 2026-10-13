package com.cravego.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final double FREE_DELIVERY_LIMIT =
            499.0;

    private static final double DELIVERY_FEE =
            40.0;

    private static final double PLATFORM_FEE =
            5.0;

    private MenuDAO menuDAO;
    private RestaurantDAO restaurantDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() {

        menuDAO =
                new MenuDAOImpl();

        restaurantDAO =
                new RestaurantDAOImpl();

        orderDAO =
                new OrderDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        CheckoutData checkoutData =
                loadCheckoutData(session);

        if (checkoutData == null
                || checkoutData.getCartItems().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/cart"
            );

            return;
        }

        setCheckoutAttributes(
                request,
                checkoutData
        );

        request.getRequestDispatcher(
                "/checkout.jsp"
        ).forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession(false);

        User loggedInUser =
                getLoggedInUser(session);

        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        CheckoutData checkoutData =
                loadCheckoutData(session);

        if (checkoutData == null
                || checkoutData.getCartItems().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/cart"
            );

            return;
        }

        String paymentMode =
                request.getParameter(
                        "paymentMode"
                );

        if (!isValidPaymentMode(paymentMode)) {

            request.setAttribute(
                    "errorMessage",
                    "Please select a valid payment method."
            );

            setCheckoutAttributes(
                    request,
                    checkoutData
            );

            request.getRequestDispatcher(
                    "/checkout.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }

        Order order =
                createOrder(
                        loggedInUser,
                        checkoutData,
                        paymentMode
                );

        List<OrderItem> orderItems =
                createOrderItems(
                        checkoutData.getCartItems()
                );

        int orderId =
                orderDAO.placeOrder(
                        order,
                        orderItems
                );

        if (orderId <= 0) {

            request.setAttribute(
                    "errorMessage",
                    "We could not place your order. "
                    + "Please try again."
            );

            setCheckoutAttributes(
                    request,
                    checkoutData
            );

            request.getRequestDispatcher(
                    "/checkout.jsp"
            ).forward(
                    request,
                    response
            );

            return;
        }

        /*
         * Clear the cart only after the complete
         * database transaction succeeds.
         */
        session.removeAttribute("cart");
        session.removeAttribute("cartRestaurantId");

        /*
         * Temporarily store the successful order details
         * for order-success.jsp.
         */
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
                checkoutData.getRestaurant()
        );

        response.sendRedirect(
                request.getContextPath()
                + "/order-success.jsp"
        );
    }

    private User getLoggedInUser(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute(
                "loggedInUser"
        );
    }

    @SuppressWarnings("unchecked")
    private CheckoutData loadCheckoutData(
            HttpSession session) {

        if (session == null) {
            return null;
        }

        Map<Integer, Integer> cart =
                (Map<Integer, Integer>)
                session.getAttribute("cart");

        Integer restaurantId =
                (Integer) session.getAttribute(
                        "cartRestaurantId"
                );

        if (cart == null
                || cart.isEmpty()
                || restaurantId == null) {

            return null;
        }

        Restaurant restaurant =
                restaurantDAO.getRestaurantById(
                        restaurantId
                );

        if (restaurant == null) {
            return null;
        }

        Map<Menu, Integer> cartItems =
                new LinkedHashMap<>();

        double subtotal = 0.0;
        int totalQuantity = 0;

        for (
            Map.Entry<Integer, Integer> entry
                    : cart.entrySet()
        ) {

            Integer menuId =
                    entry.getKey();

            Integer quantity =
                    entry.getValue();

            if (menuId == null
                    || quantity == null
                    || quantity <= 0) {

                continue;
            }

            /*
             * Maximum quantity allowed per item.
             */
            int validQuantity =
                    Math.min(quantity, 10);

            Menu menu =
                    menuDAO.getMenuById(
                            menuId
                    );

            if (menu == null
                    || !menu.isAvailable()
                    || menu.getRestaurantId()
                            != restaurantId) {

                continue;
            }

            cartItems.put(
                    menu,
                    validQuantity
            );

            subtotal +=
                    menu.getPrice()
                    * validQuantity;

            totalQuantity +=
                    validQuantity;
        }

        if (cartItems.isEmpty()) {
            return null;
        }

        double deliveryFee =
                subtotal >= FREE_DELIVERY_LIMIT
                ? 0.0
                : DELIVERY_FEE;

        double totalAmount =
                subtotal
                + deliveryFee
                + PLATFORM_FEE;

        return new CheckoutData(
                restaurant,
                cartItems,
                subtotal,
                deliveryFee,
                PLATFORM_FEE,
                totalAmount,
                totalQuantity
        );
    }

    private void setCheckoutAttributes(
            HttpServletRequest request,
            CheckoutData checkoutData) {

        request.setAttribute(
                "restaurant",
                checkoutData.getRestaurant()
        );

        request.setAttribute(
                "cartItems",
                checkoutData.getCartItems()
        );

        request.setAttribute(
                "subtotal",
                checkoutData.getSubtotal()
        );

        request.setAttribute(
                "deliveryFee",
                checkoutData.getDeliveryFee()
        );

        request.setAttribute(
                "platformFee",
                checkoutData.getPlatformFee()
        );

        request.setAttribute(
                "totalAmount",
                checkoutData.getTotalAmount()
        );

        request.setAttribute(
                "totalQuantity",
                checkoutData.getTotalQuantity()
        );
    }

    private boolean isValidPaymentMode(
            String paymentMode) {

        if (paymentMode == null) {
            return false;
        }

        return paymentMode.equals("COD")
                || paymentMode.equals("UPI");
    }

    private Order createOrder(
            User loggedInUser,
            CheckoutData checkoutData,
            String paymentMode) {

        Order order =
                new Order();

        order.setUserId(
                loggedInUser.getUserId()
        );

        order.setRestaurantId(
                checkoutData
                    .getRestaurant()
                    .getRestaurantId()
        );

        order.setOrderDate(
                LocalDateTime.now()
        );

        order.setTotalAmount(
                checkoutData.getTotalAmount()
        );

        order.setStatus("PLACED");

        order.setPaymentMode(
                paymentMode
        );

        return order;
    }

    private List<OrderItem> createOrderItems(
            Map<Menu, Integer> cartItems) {

        List<OrderItem> orderItems =
                new ArrayList<>();

        for (
            Map.Entry<Menu, Integer> entry
                    : cartItems.entrySet()
        ) {

            Menu menu =
                    entry.getKey();

            int quantity =
                    entry.getValue();

            OrderItem orderItem =
                    new OrderItem();

            orderItem.setMenuId(
                    menu.getMenuId()
            );

            orderItem.setQuantity(
                    quantity
            );

            orderItem.setTotalAmount(
                    menu.getPrice()
                    * quantity
            );

            orderItems.add(
                    orderItem
            );
        }

        return orderItems;
    }

    private static class CheckoutData {

        private final Restaurant restaurant;

        private final Map<Menu, Integer> cartItems;

        private final double subtotal;

        private final double deliveryFee;

        private final double platformFee;

        private final double totalAmount;

        private final int totalQuantity;

        private CheckoutData(
                Restaurant restaurant,
                Map<Menu, Integer> cartItems,
                double subtotal,
                double deliveryFee,
                double platformFee,
                double totalAmount,
                int totalQuantity) {

            this.restaurant =
                    restaurant;

            this.cartItems =
                    cartItems;

            this.subtotal =
                    subtotal;

            this.deliveryFee =
                    deliveryFee;

            this.platformFee =
                    platformFee;

            this.totalAmount =
                    totalAmount;

            this.totalQuantity =
                    totalQuantity;
        }

        public Restaurant getRestaurant() {
            return restaurant;
        }

        public Map<Menu, Integer> getCartItems() {
            return cartItems;
        }

        public double getSubtotal() {
            return subtotal;
        }

        public double getDeliveryFee() {
            return deliveryFee;
        }

        public double getPlatformFee() {
            return platformFee;
        }

        public double getTotalAmount() {
            return totalAmount;
        }

        public int getTotalQuantity() {
            return totalQuantity;
        }
    }
}