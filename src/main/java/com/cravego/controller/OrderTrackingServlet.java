package com.cravego.controller;

import java.io.IOException;
import java.util.List;

import com.cravego.dao.OrderDAO;
import com.cravego.dao.OrderItemDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.daoimpl.OrderItemDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
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

@WebServlet("/track-order")
public class OrderTrackingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;
    private OrderItemDAO orderItemDAO;
    private RestaurantDAO restaurantDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAOImpl();
        orderItemDAO = new OrderItemDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User loggedInUser = session == null
                ? null
                : (User) session.getAttribute("loggedInUser");

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/login?message=Please login to track your order");
            return;
        }

        String orderIdParameter = request.getParameter("orderId");

        if (orderIdParameter == null
                || orderIdParameter.isBlank()) {

            response.sendRedirect(
                    request.getContextPath() + "/restaurants");
            return;
        }

        int orderId;

        try {
            orderId = Integer.parseInt(orderIdParameter);
        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID.");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Order not found.");
            return;
        }

        /*
         * Prevent one customer from viewing another
         * customer's order by changing the orderId
         * in the browser URL.
         */
        if (order.getUserId() != loggedInUser.getUserId()) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to view this order.");
            return;
        }

        Restaurant restaurant =
                restaurantDAO.getRestaurantById(
                        order.getRestaurantId());

        List<OrderItem> orderItems =
                orderItemDAO.getOrderItemsByOrderId(orderId);

        request.setAttribute("order", order);
        request.setAttribute("restaurant", restaurant);
        request.setAttribute("orderItems", orderItems);

        request.getRequestDispatcher("/order-tracking.jsp")
                .forward(request, response);
    }
}