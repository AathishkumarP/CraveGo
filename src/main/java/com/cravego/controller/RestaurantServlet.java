package com.cravego.controller;

import java.io.IOException;
import java.util.List;

import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
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
    public void init() throws ServletException {

        restaurantDAO =
                new RestaurantDAOImpl();
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

        String searchText =
                request.getParameter("search");

        String cuisineType =
                request.getParameter("cuisine");

        List<Restaurant> restaurants;

        String pageTitle;

        /*
         * Search is given first priority.
         *
         * Example:
         * /restaurants?search=biryani
         */
        if (searchText != null
                && !searchText.trim().isEmpty()) {

            searchText = searchText.trim();

            restaurants =
                    restaurantDAO.searchRestaurants(
                            searchText
                    );

            pageTitle =
                    "Search results for \""
                    + searchText
                    + "\"";

            request.setAttribute(
                    "searchText",
                    searchText
            );

        /*
         * Cuisine filtering.
         *
         * Example:
         * /restaurants?cuisine=South Indian
         */
        } else if (cuisineType != null
                && !cuisineType.trim().isEmpty()) {

            cuisineType = cuisineType.trim();

            restaurants =
                    restaurantDAO
                        .getRestaurantsByCuisine(
                            cuisineType
                        );

            pageTitle =
                    cuisineType + " Restaurants";

            request.setAttribute(
                    "selectedCuisine",
                    cuisineType
            );

        /*
         * No search or cuisine parameter.
         *
         * Example:
         * /restaurants
         */
        } else {

            restaurants =
                    restaurantDAO.getAllRestaurants();

            pageTitle =
                    "Restaurants in Bengaluru";
        }

        request.setAttribute(
                "restaurants",
                restaurants
        );

        request.setAttribute(
                "pageTitle",
                pageTitle
        );

        request.setAttribute(
                "resultCount",
                restaurants.size()
        );

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                        "/restaurants.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }
}