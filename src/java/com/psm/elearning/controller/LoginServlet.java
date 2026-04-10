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
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;

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
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");

        if (identifier == null || identifier.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Identifier and password are required.");
            request.setAttribute("identifier", identifier != null ? identifier.trim() : "");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        String trimmedIdentifier = identifier.trim();
        String identifierUpper = trimmedIdentifier.toUpperCase(Locale.ROOT);
        User user = null;

        if (identifierUpper.matches("PSM\\d+")) {
            Student student = studentDAO.findByRegNumber(identifierUpper);
            if (student != null) {
                user = userDAO.findById(student.getUserId());
            }
        }

        if (user == null) {
            user = userDAO.findByEmail(trimmedIdentifier.toLowerCase(Locale.ROOT));
        }

        if (user == null) {
            request.setAttribute("error", "Invalid credentials.");
            request.setAttribute("identifier", trimmedIdentifier);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        if (!User.STATUS_ACTIVE.equals(user.getStatus())) {
            request.setAttribute("error", "Your account is " + user.getStatus() + ". Please contact support.");
            request.setAttribute("identifier", trimmedIdentifier);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        if (!PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            request.setAttribute("error", "Invalid credentials.");
            request.setAttribute("identifier", trimmedIdentifier);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        userDAO.updateLastLogin(user.getUserId());

        HttpSession existingSession = request.getSession(false);
        if (existingSession != null) {
            existingSession.invalidate();
        }

        HttpSession session = request.getSession(true);
        session.setMaxInactiveInterval(
                AppSettingsService.getInt(AppSettingsService.KEY_SECURITY_SESSION_TIMEOUT, 30, 5, 480) * 60
        );
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("role", user.getRole());
        session.setAttribute("userRole", user.getRole());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userName", user.getFullName());

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
            default:
                break;
        }

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
