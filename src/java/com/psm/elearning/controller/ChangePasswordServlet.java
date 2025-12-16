package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ChangePasswordServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validation
        if (currentPassword == null || currentPassword.trim().isEmpty() ||
            newPassword == null || newPassword.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        // Check new password length
        if (newPassword.length() < 6) {
            request.setAttribute("error", "New password must be at least 6 characters long.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        // Check new password match
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        // Verify current password
        User user = userDAO.findById(sessionUser.getUserId());
        if (user == null) {
            request.setAttribute("error", "User not found.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        if (!PasswordUtil.verifyPassword(currentPassword, user.getPasswordHash())) {
            request.setAttribute("error", "Current password is incorrect.");
            request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
            return;
        }

        // Hash new password and update
        String newPasswordHash = PasswordUtil.hashPassword(newPassword);
        user.setPasswordHash(newPasswordHash);
        
        boolean updated = userDAO.update(user);
        
        if (updated) {
            // Send password change confirmation email
            try {
                com.psm.elearning.util.EmailUtil.sendPasswordChangeConfirmation(
                    user.getEmail(),
                    user.getFullName()
                );
            } catch (Exception emailEx) {
                System.err.println("Failed to send password change confirmation: " + emailEx.getMessage());
            }
            
            request.setAttribute("success", "Password changed successfully! A confirmation email has been sent.");
        } else {
            request.setAttribute("error", "Failed to change password. Please try again.");
        }

        request.getRequestDispatcher("/WEB-INF/views/change-password.jsp").forward(request, response);
    }
}
