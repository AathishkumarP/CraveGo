package com.cravego.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.cravego.dao.OrderDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Order;
import com.cravego.model.Restaurant;
import com.cravego.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/my-orders")
public class MyOrdersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;
    private RestaurantDAO restaurantDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        User loggedInUser = null;

        if (session != null
                && session.getAttribute("loggedInUser") instanceof User) {

            loggedInUser =
                    (User) session.getAttribute("loggedInUser");
        }

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        List<Order> orders = orderDAO.getOrdersByUserId(
                loggedInUser.getUserId()
        );

        Map<Integer, Restaurant> restaurantMap = new HashMap<>();

        for (Order order : orders) {
            int restaurantId = order.getRestaurantId();

            // Fetch each restaurant only once for this request.
            // A null value also records an unavailable restaurant.
            if (!restaurantMap.containsKey(restaurantId)) {
                Restaurant restaurant =
                        restaurantDAO.getRestaurantById(restaurantId);

                restaurantMap.put(restaurantId, restaurant);
            }
        }

        request.setAttribute("orders", orders);
        request.setAttribute("restaurantMap", restaurantMap);

        request.getRequestDispatcher("/my-orders.jsp")
               .forward(request, response);
    }
}