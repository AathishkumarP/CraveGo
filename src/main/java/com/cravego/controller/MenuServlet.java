package com.cravego.controller;

import java.io.IOException;
import java.util.List;

import com.cravego.dao.MenuDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Menu;
import com.cravego.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDAO menuDAO;
    private RestaurantDAO restaurantDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAOImpl();
        restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String restaurantIdValue =
                request.getParameter("restaurantId");

        if (restaurantIdValue == null
                || restaurantIdValue.trim().isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        try {

            int restaurantId =
                    Integer.parseInt(restaurantIdValue);

            Restaurant restaurant =
                    restaurantDAO.getRestaurantById(
                            restaurantId
                    );

            if (restaurant == null
                    || !restaurant.isActive()) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/restaurants"
                );

                return;
            }

            List<Menu> menuItems =
                    menuDAO.getAvailableMenuByRestaurantId(
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

            request.getRequestDispatcher("/menu.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );
        }
    }
}