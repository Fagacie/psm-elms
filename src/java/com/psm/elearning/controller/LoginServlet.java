package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.InstructorDAO;
import com.psm.elearning.dao.InstructorDAOImpl;
import com.psm.elearning.dao.AdminDAO;
import com.psm.elearning.dao.AdminDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.Instructor;
import com.psm.elearning.model.Admin;
import com.psm.elearning.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private StudentDAO studentDAO;
    private InstructorDAO instructorDAO;
    private AdminDAO adminDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
        studentDAO = new StudentDAOImpl();
        instructorDAO = new InstructorDAOImpl();
        adminDAO = new AdminDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String role = request.getParameter("role");
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");

        // Validate input
        if (role == null || role.trim().isEmpty() || identifier == null || identifier.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Role, identifier and password are required.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }
        User user = null;
        if ("Student".equalsIgnoreCase(role)) {
            // Decide if identifier is reg number or email
            if (identifier.toUpperCase().startsWith("PSM") && identifier.toUpperCase().matches("PSM\\d+")) {
                Student student = studentDAO.findByRegNumber(identifier.trim().toUpperCase());
                if (student != null) {
                    user = userDAO.findById(student.getUserId());
                }
            } else {
                user = userDAO.findByEmail(identifier.trim());
            }
        } else {
            // Instructor/Admin always by email
            user = userDAO.findByEmail(identifier.trim());
        }
        
        if (user == null) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        // Check account status
        if (!User.STATUS_ACTIVE.equals(user.getStatus())) {
            request.setAttribute("error", "Your account is " + user.getStatus() + ". Please contact support.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        // Verify password
        if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        // Update last login
        userDAO.updateLastLogin(user.getUserId());

        // Create session and set attributes
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("role", user.getRole()); // Used by enrollment servlets
        session.setAttribute("userRole", user.getRole());
        session.setAttribute("email", user.getEmail()); // Required for Paystack payment
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userName", user.getFullName());

        // Load role-specific data
        switch (user.getRole()) {
            case User.ROLE_STUDENT:
                Student student = studentDAO.findByUserId(user.getUserId());
                session.setAttribute("student", student);
                break;
            case User.ROLE_INSTRUCTOR:
                Instructor instructor = instructorDAO.findByUserId(user.getUserId());
                session.setAttribute("instructor", instructor);
                break;
            case User.ROLE_ADMIN:
                Admin admin = adminDAO.findByUserId(user.getUserId());
                session.setAttribute("admin", admin);
                break;
        }

        // Redirect to dashboard
        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
