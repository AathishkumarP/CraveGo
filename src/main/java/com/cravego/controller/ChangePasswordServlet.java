package com.cravego.controller;

import java.io.IOException;
import java.util.UUID;

import com.cravego.dao.UserDAO;
import com.cravego.daoimpl.UserDAOImpl;
import com.cravego.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        prepareResponse(response);

        User loggedInUser = getLoggedInUser(request);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        HttpSession session = request.getSession(false);

        if (!(session.getAttribute("passwordCsrfToken")
                instanceof String)) {

            session.setAttribute(
                    "passwordCsrfToken",
                    UUID.randomUUID().toString()
            );
        }

        request.setAttribute("passwordFormReady", Boolean.TRUE);

        request.getRequestDispatcher("/change-password.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        prepareResponse(response);

        User loggedInUser = getLoggedInUser(request);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        HttpSession session = request.getSession(false);

        Object expectedToken =
                session.getAttribute("passwordCsrfToken");

        String submittedToken =
                request.getParameter("csrfToken");

        if (!(expectedToken instanceof String)
                || !expectedToken.equals(submittedToken)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Your form session is invalid. "
                    + "Reopen Change Password."
            );
            return;
        }

        // Preserve password characters exactly, including spaces.
        String currentPassword =
                request.getParameter("currentPassword");

        String newPassword =
                request.getParameter("newPassword");

        String confirmPassword =
                request.getParameter("confirmPassword");

        String validationError = validate(
                currentPassword,
                newPassword,
                confirmPassword
        );

        if (validationError != null) {
            forwardWithError(
                    request,
                    response,
                    validationError
            );
            return;
        }

        // The user ID comes only from the authenticated session.
        boolean changed = userDAO.changePassword(
                loggedInUser.getUserId(),
                currentPassword,
                newPassword
        );

        if (!changed) {
            forwardWithError(
                    request,
                    response,
                    "Unable to change your password. "
                    + "Check your current password and try again."
            );
            return;
        }

        // Rotate this session's ID after changing credentials.
        request.changeSessionId();

        session.setAttribute(
                "passwordCsrfToken",
                UUID.randomUUID().toString()
        );

        session.setAttribute(
                "profileSuccessMessage",
                "Your password has been changed successfully."
        );

        response.sendRedirect(
                request.getContextPath() + "/profile"
        );
    }

    private User getLoggedInUser(HttpServletRequest request) {

        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        Object user = session.getAttribute("loggedInUser");

        return user instanceof User ? (User) user : null;
    }

    private String validate(
            String currentPassword,
            String newPassword,
            String confirmPassword) {

        if (currentPassword == null || currentPassword.isEmpty()) {
            return "Please enter your current password.";
        }

        if (newPassword == null || newPassword.isBlank()) {
            return "Please enter a new password.";
        }

        if (newPassword.length() < 8) {
            return "Your new password must contain at least 8 characters.";
        }

        if (confirmPassword == null
                || !newPassword.equals(confirmPassword)) {
            return "The new password and confirmation do not match.";
        }

        if (currentPassword.equals(newPassword)) {
            return "Choose a password different from your current password.";
        }

        return null;
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            String errorMessage)
            throws ServletException, IOException {

        // Password values are not copied into page attributes.
        request.setAttribute("errorMessage", errorMessage);
        request.setAttribute("passwordFormReady", Boolean.TRUE);

        request.getRequestDispatcher("/change-password.jsp")
               .forward(request, response);
    }

    private void prepareResponse(HttpServletResponse response) {
        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
    }
}