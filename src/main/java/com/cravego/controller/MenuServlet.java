package com.cravego.controller;

import java.io.IOException;
import java.util.List;

import com.cravego.dao.MenuDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Menu;
import com.cravego.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RestaurantDAO restaurantDAO;

    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {

        restaurantDAO =
                new RestaurantDAOImpl();

        menuDAO =
                new MenuDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        response.setContentType(
                "text/html; charset=UTF-8"
        );

        String restaurantIdParameter =
                request.getParameter("restaurantId");

        if (restaurantIdParameter == null
                || restaurantIdParameter.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        int restaurantId;

        try {

            restaurantId =
                    Integer.parseInt(
                        restaurantIdParameter.trim()
                    );

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        if (restaurantId <= 0) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        Restaurant restaurant =
                restaurantDAO.getRestaurantById(
                        restaurantId
                );

        if (restaurant == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        List<Menu> menuItems =
                menuDAO.getMenuByRestaurantId(
                        restaurantId
                );

        request.setAttribute(
                "restaurant",
                restaurant
        );

        request.setAttribute(
                "menuItems",
                menuItems
        );

        request.setAttribute(
                "menuItemCount",
                menuItems == null
                ? 0
                : menuItems.size()
        );

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                        "/menu.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }
}