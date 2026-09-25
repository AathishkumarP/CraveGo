package com.cravego.controller;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.cravego.dao.MenuDAO;
import com.cravego.dao.RestaurantDAO;
import com.cravego.daoimpl.MenuDAOImpl;
import com.cravego.daoimpl.RestaurantDAOImpl;
import com.cravego.model.Menu;
import com.cravego.model.Restaurant;
import com.cravego.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class ViewCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int MAX_QUANTITY = 10;

    private MenuDAO menuDAO;

    private RestaurantDAO restaurantDAO;

    @Override
    public void init() throws ServletException {

        menuDAO =
                new MenuDAOImpl();

        restaurantDAO =
                new RestaurantDAOImpl();
    }

    /* =========================
       DISPLAY CART
    ========================= */

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        response.setContentType(
                "text/html; charset=UTF-8"
        );

        HttpSession session =
                request.getSession();

        User loggedInUser =
                (User) session.getAttribute(
                        "loggedInUser"
                );

        /*
         * The cart requires login.
         */
        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        Map<Integer, Integer> cart =
                getSessionCart(session);

        Map<Menu, Integer> cartItems =
                new LinkedHashMap<>();

        double subtotal = 0.0;

        /*
         * Load complete Menu objects using
         * the menu IDs stored in the session.
         */
        for (
            Map.Entry<Integer, Integer> entry
                : cart.entrySet()
        ) {

            int menuId =
                    entry.getKey();

            int quantity =
                    entry.getValue();

            Menu menu =
                    menuDAO.getMenuById(menuId);

            if (menu != null && quantity > 0) {

                cartItems.put(
                        menu,
                        quantity
                );

                subtotal +=
                        menu.getPrice()
                        * quantity;
            }
        }

        /*
         * Delivery is free for orders
         * worth ₹499 or above.
         */
        double deliveryFee =
                subtotal == 0.0
                ? 0.0
                : subtotal >= 499.0
                    ? 0.0
                    : 40.0;

        double platformFee =
                subtotal == 0.0
                ? 0.0
                : 5.0;

        double totalAmount =
                subtotal
                + deliveryFee
                + platformFee;

        Integer cartRestaurantId =
                (Integer) session.getAttribute(
                        "cartRestaurantId"
                );

        Restaurant restaurant = null;

        if (cartRestaurantId != null) {

            restaurant =
                    restaurantDAO.getRestaurantById(
                            cartRestaurantId
                    );
        }

        int totalQuantity = 0;

        for (Integer quantity : cart.values()) {

            if (quantity != null
                    && quantity > 0) {

                totalQuantity += quantity;
            }
        }

        request.setAttribute(
                "cartItems",
                cartItems
        );

        request.setAttribute(
                "restaurant",
                restaurant
        );

        request.setAttribute(
                "subtotal",
                subtotal
        );

        request.setAttribute(
                "deliveryFee",
                deliveryFee
        );

        request.setAttribute(
                "platformFee",
                platformFee
        );

        request.setAttribute(
                "totalAmount",
                totalAmount
        );

        request.setAttribute(
                "totalQuantity",
                totalQuantity
        );

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                        "/cart.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }

    /* =========================
       UPDATE CART
    ========================= */

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

        if (loggedInUser == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login"
            );

            return;
        }

        String action =
                request.getParameter("action");

        Map<Integer, Integer> cart =
                getSessionCart(session);

        /*
         * Clear the complete cart.
         */
        if ("clear".equalsIgnoreCase(action)) {

            cart.clear();

            session.removeAttribute(
                    "cartRestaurantId"
            );

            redirectAfterAction(
                    request,
                    response
            );

            return;
        }

        String menuIdParameter =
                request.getParameter("menuId");

        int menuId;

        try {

            menuId =
                    Integer.parseInt(
                        menuIdParameter
                    );

        } catch (
            NumberFormatException
            | NullPointerException e
        ) {

            redirectAfterAction(
                    request,
                    response
            );

            return;
        }

        if (!cart.containsKey(menuId)) {

            redirectAfterAction(
                    request,
                    response
            );

            return;
        }

        int currentQuantity =
                cart.get(menuId);

        /*
         * Increase quantity.
         */
        if ("increase".equalsIgnoreCase(action)) {

            if (currentQuantity
                    < MAX_QUANTITY) {

                cart.put(
                        menuId,
                        currentQuantity + 1
                );
            }

        /*
         * Decrease quantity.
         *
         * Quantity 1 becomes 0, so the
         * item is removed from the cart.
         */
        } else if (
            "decrease".equalsIgnoreCase(action)
        ) {

            if (currentQuantity > 1) {

                cart.put(
                        menuId,
                        currentQuantity - 1
                );

            } else {

                cart.remove(menuId);
            }

        /*
         * Remove a specific item.
         */
        } else if (
            "remove".equalsIgnoreCase(action)
        ) {

            cart.remove(menuId);
        }

        /*
         * Remove the selected restaurant
         * when the cart becomes empty.
         */
        if (cart.isEmpty()) {

            session.removeAttribute(
                    "cartRestaurantId"
            );
        }

        redirectAfterAction(
                request,
                response
        );
    }

    /* =========================
       GET OR CREATE CART
    ========================= */

    private Map<Integer, Integer> getSessionCart(
            HttpSession session) {

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

        return cart;
    }

    /* =========================
       SAFE REDIRECTION
    ========================= */

    private void redirectAfterAction(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String returnTo =
                request.getParameter("returnTo");

        String restaurantIdParameter =
                request.getParameter(
                        "restaurantId"
                );

        /*
         * Redirect back to the menu only
         * when an exact supported value
         * and valid restaurant ID are given.
         */
        if ("menu".equals(returnTo)
                && isPositiveInteger(
                        restaurantIdParameter
                )) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/menu?restaurantId="
                    + restaurantIdParameter
            );

            return;
        }

        /*
         * Default destination is the cart.
         */
        response.sendRedirect(
                request.getContextPath()
                + "/cart"
        );
    }

    private boolean isPositiveInteger(
            String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return false;
        }

        try {

            return Integer.parseInt(
                    value.trim()
            ) > 0;

        } catch (NumberFormatException e) {

            return false;
        }
    }
}