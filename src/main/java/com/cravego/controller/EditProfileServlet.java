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

@WebServlet("/edit-profile")
public class EditProfileServlet extends HttpServlet {

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

        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        User loggedInUser = getLoggedInUser(request);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User profileUser = userDAO.getUserById(
                loggedInUser.getUserId()
        );

        if (profileUser == null) {
            response.sendError(
                    HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Your profile could not be loaded. Please try again."
            );
            return;
        }

        profileUser.setPassword(null);

        HttpSession session = request.getSession(false);

        if (session.getAttribute("profileCsrfToken") == null) {
            session.setAttribute(
                    "profileCsrfToken",
                    UUID.randomUUID().toString()
            );
        }

        request.setAttribute("profileUser", profileUser);

        request.getRequestDispatcher("/edit-profile.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        User loggedInUser = getLoggedInUser(request);

        if (loggedInUser == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        HttpSession session = request.getSession(false);

        Object expectedToken =
                session.getAttribute("profileCsrfToken");

        String submittedToken =
                request.getParameter("csrfToken");

        if (!(expectedToken instanceof String)
                || !expectedToken.equals(submittedToken)) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Your form session is invalid. Reopen Edit Profile."
            );
            return;
        }

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String address = trim(request.getParameter("address"));

        User submittedUser = new User();

        // Never take the user ID, role or password from form input.
        submittedUser.setUserId(loggedInUser.getUserId());
        submittedUser.setUsername(username);
        submittedUser.setEmail(email);
        submittedUser.setPhone(phone);
        submittedUser.setAddress(address);

        String validationError = validate(
                username,
                email,
                phone,
                address
        );

        if (validationError != null) {
            forwardWithError(
                    request,
                    response,
                    submittedUser,
                    validationError
            );
            return;
        }

        User existingUser = userDAO.getUserByEmail(email);

        if (existingUser != null
                && existingUser.getUserId()
                        != loggedInUser.getUserId()) {

            forwardWithError(
                    request,
                    response,
                    submittedUser,
                    "This email address belongs to another account."
            );
            return;
        }

        boolean updated = userDAO.updateProfile(submittedUser);

        if (!updated) {
            forwardWithError(
                    request,
                    response,
                    submittedUser,
                    "Unable to save your profile. Please try again "
                    + "or use a different email address."
            );
            return;
        }

        // Create a new session user object without storing the password.
        User refreshedUser = new User();

        refreshedUser.setUserId(loggedInUser.getUserId());
        refreshedUser.setUsername(username);
        refreshedUser.setEmail(email);
        refreshedUser.setPhone(phone);
        refreshedUser.setAddress(address);
        refreshedUser.setRole(loggedInUser.getRole());
        refreshedUser.setPassword(null);

        session.setAttribute("loggedInUser", refreshedUser);

        session.setAttribute(
                "profileCsrfToken",
                UUID.randomUUID().toString()
        );

        session.setAttribute(
                "profileSuccessMessage",
                "Your profile has been updated successfully."
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

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String validate(
            String username,
            String email,
            String phone,
            String address) {

        if (username.length() < 2 || username.length() > 50) {
            return "Username must contain between 2 and 50 characters.";
        }

        if (email.length() > 100
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Please enter a valid email address "
                    + "with no more than 100 characters.";
        }

        if (!phone.matches("^[6-9][0-9]{9}$")) {
            return "Please enter a valid 10-digit Indian mobile number.";
        }

        if (address.length() < 5 || address.length() > 255) {
            return "Delivery address must contain "
                    + "between 5 and 255 characters.";
        }

        return null;
    }

    private void forwardWithError(
            HttpServletRequest request,
            HttpServletResponse response,
            User profileUser,
            String errorMessage)
            throws ServletException, IOException {

        request.setAttribute("profileUser", profileUser);
        request.setAttribute("errorMessage", errorMessage);

        request.getRequestDispatcher("/edit-profile.jsp")
               .forward(request, response);
    }
}