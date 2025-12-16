package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.PasswordResetTokenDAO;
import com.psm.elearning.dao.PasswordResetTokenDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.PasswordResetToken;
import com.psm.elearning.util.PasswordUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ResetPasswordServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAOImpl();
    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset link");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Validate token
        PasswordResetToken resetToken = tokenDAO.findByToken(token);
        
        if (resetToken == null) {
            request.setAttribute("error", "Invalid reset link");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!resetToken.isValid()) {
            String errorMsg = resetToken.isUsed() ? "This reset link has already been used" : "This reset link has expired";
            request.setAttribute("error", errorMsg);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Token is valid, show reset form
        request.setAttribute("token", token);
        request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate inputs
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset link");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (newPassword == null || newPassword.trim().isEmpty()) {
            request.setAttribute("error", "Password is required");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Validate token
        PasswordResetToken resetToken = tokenDAO.findByToken(token);
        
        if (resetToken == null || !resetToken.isValid()) {
            request.setAttribute("error", "Invalid or expired reset link");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Get user
        User user = userDAO.findById(resetToken.getUserId());
        if (user == null) {
            request.setAttribute("error", "User not found");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }
        
        // Update password
        String hashedPassword = PasswordUtil.hashPassword(newPassword);
        user.setPasswordHash(hashedPassword);
        
        if (userDAO.update(user)) {
            // Mark token as used
            tokenDAO.markAsUsed(token);
            
            request.setAttribute("success", "Password reset successful! You can now login with your new password.");
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update password. Please try again.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
        }
    }
}
