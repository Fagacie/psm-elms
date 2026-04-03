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

        response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
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
            session.setAttribute("passwordError", "All fields are required.");
            response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
            return;
        }

        // Check new password length
        if (newPassword.length() < 6) {
            session.setAttribute("passwordError", "New password must be at least 6 characters long.");
            response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
            return;
        }

        // Check new password match
        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("passwordError", "New passwords do not match.");
            response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
            return;
        }

        // Verify current password
        User user = userDAO.findById(sessionUser.getUserId());
        if (user == null) {
            session.setAttribute("passwordError", "User not found.");
            response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
            return;
        }

        if (!PasswordUtil.verifyPassword(currentPassword, user.getPasswordHash())) {
            session.setAttribute("passwordError", "Current password is incorrect.");
            response.sendRedirect(request.getContextPath() + "/profile?openPasswordModal=1");
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
            
            session.setAttribute("passwordSuccess", "Password changed successfully! A confirmation email has been sent.");
        } else {
            session.setAttribute("passwordError", "Failed to change password. Please try again.");
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
