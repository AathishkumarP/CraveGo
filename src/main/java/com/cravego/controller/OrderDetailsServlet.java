package com.cravego.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.cravego.dao.MenuDAO;
import com.cravego.dao.OrderDAO;
import com.cravego.dao.OrderItemDAO;
import com.cravego.dao.RestaurantDAO;

import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.daoimpl.OrderItemDAOImpl;
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

@WebServlet("/order-details")
public class OrderDetailsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;
    private OrderItemDAO orderItemDAO;
    private RestaurantDAO restaurantDAO;
    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAOImpl();
        orderItemDAO = new OrderItemDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
        menuDAO = new MenuDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

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

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        String orderIdParameter = request.getParameter("orderId");

        int orderId;

        try {
            orderId = Integer.parseInt(
                    orderIdParameter == null
                            ? ""
                            : orderIdParameter.trim()
            );

            if (orderId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please provide a valid order ID."
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

        // Check ownership before loading any order details.
        if (order.getUserId() != loggedInUser.getUserId()) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to view this order."
            );
            return;
        }

        Restaurant restaurant =
                restaurantDAO.getRestaurantById(
                        order.getRestaurantId()
                );

        List<OrderItem> orderItems =
                orderItemDAO.getOrderItemsByOrderId(orderId);

        Map<Integer, Menu> menuMap = new HashMap<>();

        for (OrderItem orderItem : orderItems) {
            int menuId = orderItem.getMenuId();

            // Retrieve each menu item only once per request.
            if (!menuMap.containsKey(menuId)) {
                menuMap.put(
                        menuId,
                        menuDAO.getMenuById(menuId)
                );
            }
        }

        request.setAttribute("order", order);
        request.setAttribute("restaurant", restaurant);
        request.setAttribute("orderItems", orderItems);
        request.setAttribute("menuMap", menuMap);

        request.getRequestDispatcher("/order-details.jsp")
               .forward(request, response);
    }
}