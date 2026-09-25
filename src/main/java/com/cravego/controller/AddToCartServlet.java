package com.cravego.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;

import com.cravego.dao.MenuDAO;
import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.model.Menu;
import com.cravego.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/add-to-cart")
public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDAO menuDAO;

    @Override
    public void init() throws ServletException {

        menuDAO =
                new MenuDAOImpl();
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session =
                request.getSession();

        User loggedInUser =
                (User) session.getAttribute(
                        "loggedInUser"
                );

        /*
         * Cart actions require login.
         */
        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        String menuIdParameter =
                request.getParameter("menuId");

        String restaurantIdParameter =
                request.getParameter("restaurantId");

        int menuId;
        int restaurantId;

        try {

            menuId =
                    Integer.parseInt(
                        menuIdParameter
                    );

            restaurantId =
                    Integer.parseInt(
                        restaurantIdParameter
                    );

        } catch (
            NumberFormatException
            | NullPointerException e
        ) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        if (menuId <= 0 || restaurantId <= 0) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        Menu menu =
                menuDAO.getMenuById(menuId);

        /*
         * Verify that the menu item exists.
         */
        if (menu == null) {

            redirectToMenu(
                    request,
                    response,
                    restaurantId,
                    "Menu item not found."
            );

            return;
        }

        /*
         * Verify that the menu item belongs to
         * the selected restaurant.
         */
        if (menu.getRestaurantId()
                != restaurantId) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/restaurants"
            );

            return;
        }

        /*
         * Unavailable items cannot be added.
         */
        if (!menu.isAvailable()) {

            redirectToMenu(
                    request,
                    response,
                    restaurantId,
                    "This item is currently unavailable."
            );

            return;
        }

        Integer cartRestaurantId =
                (Integer) session.getAttribute(
                        "cartRestaurantId"
                );

        /*
         * Like Swiggy, one cart can contain food
         * from only one restaurant.
         */
        if (cartRestaurantId != null
                && cartRestaurantId
                        != restaurantId) {

            redirectToMenu(
                    request,
                    response,
                    restaurantId,
                    "Your cart contains items from another "
                    + "restaurant. Clear the cart before "
                    + "adding this item."
            );

            return;
        }

        Map<Integer, Integer> cart =
                (Map<Integer, Integer>)
                session.getAttribute("cart");

        if (cart == null) {

            cart = new LinkedHashMap<>();

            session.setAttribute(
                    "cart",
                    cart
            );
        }

        int currentQuantity =
                cart.getOrDefault(menuId, 0);

        cart.put(
                menuId,
                currentQuantity + 1
        );

        session.setAttribute(
                "cartRestaurantId",
                restaurantId
        );

        redirectToMenu(
                request,
                response,
                restaurantId,
                menu.getItemName()
                + " added to your cart."
        );
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/restaurants"
        );
    }

    private void redirectToMenu(
            HttpServletRequest request,
            HttpServletResponse response,
            int restaurantId,
            String message)
            throws IOException {

        String encodedMessage =
                URLEncoder.encode(
                    message,
                    StandardCharsets.UTF_8
                );

        response.sendRedirect(
                request.getContextPath()
                + "/menu?restaurantId="
                + restaurantId
                + "&message="
                + encodedMessage
        );
    }
}