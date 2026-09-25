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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

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
         * Redirect an already logged-in user
         * to the home page.
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
                        "/login.jsp"
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

        String email =
                request.getParameter("email");

        String password =
                request.getParameter("password");

        if (email != null) {
            email = email.trim();
        }

        /*
         * Preserve the email when login fails.
         */
        request.setAttribute(
                "email",
                email
        );

        if (email == null
                || email.isEmpty()
                || password == null
                || password.isEmpty()) {

            forwardWithError(
                    request,
                    response,
                    "Please enter your email and password."
            );

            return;
        }

        User user =
                userDAO.validateUser(
                        email,
                        password
                );

        if (user == null) {

            forwardWithError(
                    request,
                    response,
                    "Invalid email or password."
            );

            return;
        }

        /*
         * Remove the old session to prevent
         * session fixation.
         */
        HttpSession oldSession =
                request.getSession(false);

        if (oldSession != null) {
            oldSession.invalidate();
        }

        HttpSession newSession =
                request.getSession(true);

        /*
         * The password is not required inside
         * the session after authentication.
         */
        user.setPassword(null);

        newSession.setAttribute(
                "loggedInUser",
                user
        );

        /*
         * Session expires after 30 minutes
         * without activity.
         */
        newSession.setMaxInactiveInterval(
                30 * 60
        );

        response.sendRedirect(
                request.getContextPath()
        );
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
                        "/login.jsp"
                );

        dispatcher.forward(
                request,
                response
        );
    }
}