package com.cravego.controller;

import java.io.IOException;

import com.cravego.dao.UserDAO;
import com.cravego.daoimpl.UserDAOImpl;
import com.cravego.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {

        userDAO =
                new UserDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        /*
         * A logged-in customer does not need
         * to access the registration page.
         */
        if (session != null
                && session.getAttribute(
                        "loggedInUser"
                ) != null) {

            response.sendRedirect(
                    request.getContextPath()
            );

            return;
        }

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                        "/register.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        response.setContentType(
                "text/html; charset=UTF-8"
        );

        String username =
                getTrimmedParameter(
                    request,
                    "username"
                );

        String email =
                getTrimmedParameter(
                    request,
                    "email"
                );

        String phone =
                getTrimmedParameter(
                    request,
                    "phone"
                );

        String address =
                getTrimmedParameter(
                    request,
                    "address"
                );

        String password =
                request.getParameter("password");

        String confirmPassword =
                request.getParameter(
                        "confirmPassword"
                );

        /*
         * Preserve entered values when validation
         * fails. Passwords are intentionally not
         * returned to the JSP.
         */
        request.setAttribute(
                "username",
                username
        );

        request.setAttribute(
                "email",
                email
        );

        request.setAttribute(
                "phone",
                phone
        );

        request.setAttribute(
                "address",
                address
        );

        if (username.isEmpty()
                || email.isEmpty()
                || phone.isEmpty()
                || address.isEmpty()
                || password == null
                || password.isEmpty()
                || confirmPassword == null
                || confirmPassword.isEmpty()) {

            forwardWithError(
                    request,
                    response,
                    "Please fill in all the fields."
            );

            return;
        }

        if (username.length() < 3
                || username.length() > 50) {

            forwardWithError(
                    request,
                    response,
                    "Username must contain between "
                    + "3 and 50 characters."
            );

            return;
        }

        if (!email.matches(
                "^[A-Za-z0-9+_.-]+"
                + "@[A-Za-z0-9.-]+$"
        )) {

            forwardWithError(
                    request,
                    response,
                    "Please enter a valid email address."
            );

            return;
        }

        if (!phone.matches("[0-9]{10}")) {

            forwardWithError(
                    request,
                    response,
                    "Phone number must contain exactly "
                    + "10 digits."
            );

            return;
        }

        if (password.length() < 6) {

            forwardWithError(
                    request,
                    response,
                    "Password must contain at least "
                    + "6 characters."
            );

            return;
        }

        if (!password.equals(confirmPassword)) {

            forwardWithError(
                    request,
                    response,
                    "Password and confirm password "
                    + "do not match."
            );

            return;
        }

        if (userDAO.isEmailExists(email)) {

            forwardWithError(
                    request,
                    response,
                    "An account already exists with "
                    + "this email address."
            );

            return;
        }

        User user =
                new User();

        user.setUsername(username);
        user.setEmail(email);
        user.setPhone(phone);
        user.setAddress(address);
        user.setPassword(password);
        user.setRole("CUSTOMER");

        int generatedUserId =
                userDAO.addUser(user);

        if (generatedUserId > 0) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login?registered=true"
            );

        } else {

            forwardWithError(
                    request,
                    response,
                    "Registration failed. Please try again."
            );
        }
    }

    private String getTrimmedParameter(
            HttpServletRequest request,
            String parameterName) {

        String value =
                request.getParameter(
                        parameterName
                );

        return value == null
                ? ""
                : value.trim();
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            String errorMessage)
            throws ServletException, IOException {

        request.setAttribute(
                "errorMessage",
                errorMessage
        );

        RequestDispatcher dispatcher =
                request.getRequestDispatcher(
                        "/register.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }
}