package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.Student;
import com.psm.elearning.util.PasswordUtil;
import com.psm.elearning.util.EmailUtil;
import com.psm.elearning.util.CloudinaryUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.time.LocalDate;

@MultipartConfig(maxFileSize = 5242880)
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
        
        // Extract user fields (from User table schema)
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String gender = request.getParameter("gender");
        
        // Student-specific fields (regNumber will be auto-generated)
        String qualification = request.getParameter("qualification");
        String country = request.getParameter("country");
        String state = request.getParameter("state");
        String emergencyContact = request.getParameter("emergencyContact");
        // Note: Passport file upload would need additional handling - TODO for later

        // Validate required fields (only core mandatory ones)
        StringBuilder missing = new StringBuilder();
        if (fullName == null || fullName.trim().isEmpty()) missing.append("Full Name, ");
        if (email == null || email.trim().isEmpty()) missing.append("Email, ");
        if (password == null || password.trim().isEmpty()) missing.append("Password, ");
        if (confirmPassword == null || confirmPassword.trim().isEmpty()) missing.append("Confirm Password, ");
        if (phone == null || phone.trim().isEmpty()) missing.append("Phone, ");
        if (country == null || country.trim().isEmpty()) missing.append("Country, ");
        // Optional: dobStr, gender, qualification, state, emergencyContact are NOT required
        if (missing.length() > 0) {
            // Remove trailing comma and space
            String list = missing.substring(0, missing.length() - 2);
            request.setAttribute("error", "Missing required field(s): " + list + ".");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            request.setAttribute("error", "Invalid email format.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Check password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Validate password strength
        if (!PasswordUtil.isStrongPassword(password)) {
            request.setAttribute("error", "Password must be at least 8 characters with uppercase, lowercase, digit, and special character.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        User existingUser = userDAO.findByEmail(email.trim());
        if (existingUser != null) {
            request.setAttribute("error", "Email is already registered.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Parse date of birth only if provided (optional)
        LocalDate dob = null;
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                dob = LocalDate.parse(dobStr.trim());
            } catch (Exception e) {
                request.setAttribute("error", "Invalid date of birth format.");
                repopulateForm(request);
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }
        }

        // Create User object (matching User table schema)
        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        user.setRole(User.ROLE_STUDENT);
        user.setPhone(phone.trim());
        user.setStatus(User.STATUS_ACTIVE);

        // Create user in database
        User createdUser = userDAO.create(user);
        if (createdUser == null) {
            request.setAttribute("error", "Registration failed. Please try again.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Handle passport photo upload (optional)
        String passportUrl = null;
        try {
            Part passportPart = request.getPart("passport");
            if (passportPart != null && passportPart.getSize() > 0) {
                String fileName = Paths.get(passportPart.getSubmittedFileName()).getFileName().toString();
                String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
                
                if (fileExtension.matches("jpg|jpeg|png|gif") && passportPart.getSize() <= 5242880) {
                    byte[] fileBytes;
                    try (InputStream inputStream = passportPart.getInputStream()) {
                        fileBytes = inputStream.readAllBytes();
                    }
                    String folder = CloudinaryUtil.getPassportFolder();
                    passportUrl = CloudinaryUtil.uploadFile(fileBytes, fileName, folder, "image");
                }
            }
        } catch (Exception e) {
            System.err.println("Failed to upload passport photo during registration: " + e.getMessage());
        }

        // Create Student record (matching Student table schema)
        Student student = new Student();
        student.setUserId(createdUser.getUserId());
        // Auto-generate next registration number (starting at PSM1783 if needed)
        String generatedReg = studentDAO.getNextRegNumber();
        student.setRegNumber(generatedReg);
        student.setQualification(qualification != null && !qualification.trim().isEmpty() ? qualification.trim() : null);
        student.setCountry(country.trim());
        student.setState(state != null && !state.trim().isEmpty() ? state.trim() : null);
        student.setDob(dob); // may be null
        student.setGender(gender != null && !gender.trim().isEmpty() ? gender.trim() : null);
        student.setEmergencyContact(emergencyContact != null && !emergencyContact.trim().isEmpty() ? emergencyContact.trim() : null);
        student.setPassportPath(passportUrl);
        
        boolean studentCreated = studentDAO.create(student);
        if (!studentCreated) {
            // Rollback would require transaction management
            System.err.println("Student record creation failed for UserID: " + createdUser.getUserId());
            request.setAttribute("error", "Registration failed. Could not create student record.");
            repopulateForm(request);
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // Send registration email asynchronously (don't block registration)
        final String emailCopy = createdUser.getEmail();
        final String nameCopy = createdUser.getFullName();
        final String regCopy = generatedReg;
        new Thread(() -> {
            try {
                EmailUtil.sendRegistrationEmail(emailCopy, nameCopy, regCopy);
                System.out.println("Registration email sent to: " + emailCopy);
            } catch (Exception e) {
                System.err.println("Failed to send registration email: " + e.getMessage());
                e.printStackTrace();
            }
        }).start();

        // Redirect to login with success message
        request.getSession().setAttribute("successMessage", "Registration successful! Your Registration Number: " + generatedReg + ". Use email or reg number to login." );
        response.sendRedirect(request.getContextPath() + "/login");
    }

    private void repopulateForm(HttpServletRequest request) {
        request.setAttribute("fullName", request.getParameter("fullName"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("phone", request.getParameter("phone"));
        request.setAttribute("dob", request.getParameter("dob"));
        request.setAttribute("gender", request.getParameter("gender"));
        // regNumber removed from form; generated automatically
        request.setAttribute("qualification", request.getParameter("qualification"));
        request.setAttribute("country", request.getParameter("country"));
        request.setAttribute("state", request.getParameter("state"));
        request.setAttribute("emergencyContact", request.getParameter("emergencyContact"));
    }
}
