package com.cravego.controller;

import java.io.IOException;
import java.util.UUID;

import com.cravego.dao.OrderDAO;
import com.cravego.daoimpl.OrderDAOImpl;
import com.cravego.model.Order;
import com.cravego.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cancel-order")
public class CancelOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");

        response.sendRedirect(
                request.getContextPath() + "/my-orders"
        );
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

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        Object expectedToken =
                session.getAttribute("orderCsrfToken");

        String submittedToken =
                request.getParameter("csrfToken");

        if (!(expectedToken instanceof String)
                || !expectedToken.equals(submittedToken)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Your form session is invalid. "
                    + "Reopen the order details and try again."
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

        if (order.getUserId() != loggedInUser.getUserId()) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "You are not allowed to cancel this order."
            );
            return;
        }

        /*
         * The DAO checks ownership and PLACED status again
         * in the UPDATE query to handle concurrent changes.
         */
        boolean cancelled = orderDAO.cancelOrder(
                orderId,
                loggedInUser.getUserId()
        );

        session.setAttribute(
                "orderCsrfToken",
                UUID.randomUUID().toString()
        );

        session.setAttribute(
                "orderMessage",
                cancelled
                        ? "Order #" + orderId
                                + " has been cancelled successfully."
                        : "The order could not be cancelled. "
                                + "It may no longer be in PLACED status. "
                                + "Refresh the page and try again."
        );

        session.setAttribute(
                "orderMessageType",
                cancelled ? "success" : "error"
        );

        response.sendRedirect(
                request.getContextPath()
                        + "/order-details?orderId="
                        + orderId
        );
    }
}