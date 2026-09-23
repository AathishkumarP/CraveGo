package com.cravego.controller;

import java.io.IOException;
import java.util.List;

import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/restaurants")
public class RestaurantServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RestaurantDAO restaurantDAO;

    @Override
    public void init() {
        restaurantDAO = new RestaurantDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        List<Restaurant> restaurants =
                restaurantDAO.getActiveRestaurants();

        request.setAttribute(
                "restaurants",
                restaurants
        );

        request.getRequestDispatcher("/restaurants.jsp")
               .forward(request, response);
    }
}