package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.PasswordResetTokenDAO;
import com.psm.elearning.dao.PasswordResetTokenDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.PasswordResetToken;
import com.psm.elearning.util.EmailUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

public class ForgotPasswordServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAOImpl();
    private final PasswordResetTokenDAO tokenDAO = new PasswordResetTokenDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required");
            request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Find user by email
        User user = userDAO.findByEmail(email.trim());
        
        // Always show success message (security best practice - don't reveal if email exists)
        if (user == null) {
            request.setAttribute("success", "If the email exists, a password reset link has been sent.");
            request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Invalidate any existing tokens for this user
        tokenDAO.invalidateUserTokens(user.getUserId());
        
        // Generate reset token (UUID)
        String token = UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plusHours(1); // 1 hour expiry
        
        // Save token to database
        PasswordResetToken resetToken = new PasswordResetToken(user.getUserId(), token, expiresAt);
        if (!tokenDAO.create(resetToken)) {
            request.setAttribute("error", "Failed to generate reset token. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
            return;
        }
        
        // Build reset link
        String resetLink = request.getScheme() + "://" + 
                          request.getServerName() + ":" + 
                          request.getServerPort() + 
                          request.getContextPath() + 
                          "/reset-password?token=" + token;
        
        // Send email
        try {
            boolean emailSent = EmailUtil.sendPasswordResetEmail(
                user.getEmail(),
                user.getFullName(),
                token,
                resetLink
            );
            
            if (emailSent) {
                request.setAttribute("success", "Password reset link has been sent to your email.");
            } else {
                request.setAttribute("warning", "Reset link generated but email failed to send. Please contact support.");
            }
        } catch (Exception e) {
            System.err.println("Failed to send password reset email: " + e.getMessage());
            request.setAttribute("warning", "Reset link generated but email failed to send. Please contact support.");
        }
        
        request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
    }
}
