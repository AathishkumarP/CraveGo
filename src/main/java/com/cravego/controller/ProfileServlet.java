package com.cravego.controller;

import java.io.IOException;

import com.cravego.dao.UserDAO;
import com.cravego.daoimpl.UserDAOImpl;
import com.cravego.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

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

        HttpSession session = request.getSession(false);

        if (session == null
                || !(session.getAttribute("loggedInUser")
                        instanceof User)) {

            response.sendRedirect(
                    request.getContextPath() + "/login"
            );
            return;
        }

        User loggedInUser =
                (User) session.getAttribute("loggedInUser");

        // Retrieve current details using only the authenticated user's ID.
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

        // Password is not needed by the profile page.
        profileUser.setPassword(null);

        request.setAttribute("profileUser", profileUser);

        request.getRequestDispatcher("/profile.jsp")
               .forward(request, response);
    }
}