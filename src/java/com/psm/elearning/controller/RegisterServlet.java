package com.psm.elearning.controller;

import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;
import com.psm.elearning.util.EmailUtil;
import com.psm.elearning.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Locale;

public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO;
    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
        studentDAO = new StudentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String country = trim(request.getParameter("country"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        StringBuilder missing = new StringBuilder();
        if (isBlank(fullName)) missing.append("Full Name, ");
        if (isBlank(email)) missing.append("Email, ");
        if (isBlank(phone)) missing.append("Phone Number, ");
        if (isBlank(country)) missing.append("Country, ");
        if (isBlank(password)) missing.append("Password, ");
        if (isBlank(confirmPassword)) missing.append("Confirm Password, ");

        if (missing.length() > 0) {
            String list = missing.substring(0, missing.length() - 2);
            request.setAttribute("error", "Missing required field(s): " + list + ".");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            request.setAttribute("error", "Invalid email format.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!phone.matches("^[0-9+()\\-\\s]{7,30}$")) {
            request.setAttribute("error", "Phone number format is invalid.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!PasswordUtil.isStrongPassword(password)) {
            request.setAttribute("error", "Password must be at least 8 characters with uppercase, lowercase, number, and special character.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        String normalizedEmail = email.toLowerCase(Locale.ROOT);
        if (userDAO.findByEmail(normalizedEmail) != null) {
            request.setAttribute("error", "Email is already registered.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setFullName(fullName);
        user.setEmail(normalizedEmail);
        user.setPhone(phone);
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        user.setRole(User.ROLE_STUDENT);
        user.setStatus(User.STATUS_ACTIVE);

        User createdUser = userDAO.create(user);
        if (createdUser == null) {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        Student student = new Student();
        student.setUserId(createdUser.getUserId());
        String generatedReg = studentDAO.getNextRegNumber();
        student.setRegNumber(generatedReg);
        student.setCountry(country);

        boolean studentCreated = studentDAO.create(student);
        if (!studentCreated) {
            userDAO.delete(createdUser.getUserId());
            request.setAttribute("error", "Registration failed. Could not create student record.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        final String emailCopy = createdUser.getEmail();
        final String nameCopy = createdUser.getFullName();
        final String regCopy = generatedReg;
        new Thread(() -> {
            try {
                EmailUtil.sendRegistrationEmail(emailCopy, nameCopy, regCopy);
            } catch (Exception e) {
                System.err.println("Failed to send registration email: " + e.getMessage());
            }
        }).start();

        request.getSession().setAttribute("successMessage",
            "Registration successful! Your Registration Number: " + generatedReg + ". Use it or your email to login.");
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private static String trim(String value) {
        return value == null ? null : value.trim();
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
