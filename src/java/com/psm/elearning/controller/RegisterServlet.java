package com.psm.elearning.controller;

import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.util.CloudinaryUtil;
import com.psm.elearning.util.EmailUtil;
import com.psm.elearning.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

@MultipartConfig(maxFileSize = 5242880)
public class RegisterServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());

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
        
        // Optional fields
        String dob = trim(request.getParameter("dob"));
        String gender = trim(request.getParameter("gender"));
        String state = trim(request.getParameter("state"));
        String qualification = trim(request.getParameter("qualification"));
        String emergencyContact = trim(request.getParameter("emergencyContact"));

        Part passportPhotoPart = request.getPart("passportPhoto");
        String passportPath = null;

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

        int minPasswordLength = AppSettingsService.getInt(AppSettingsService.KEY_SECURITY_MIN_PASSWORD_LENGTH, 8, 6, 64);
        if (!PasswordUtil.isStrongPassword(password) || password.length() < minPasswordLength) {
            request.setAttribute("error", "Password must be at least " + minPasswordLength + " characters with uppercase, lowercase, number, and special character.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!isBlank(gender) && !isAllowedGender(gender)) {
            request.setAttribute("error", "Gender must be Male or Female.");
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

        if (passportPhotoPart != null && passportPhotoPart.getSize() > 0) {
            String fileName = Paths.get(passportPhotoPart.getSubmittedFileName()).getFileName().toString();
            int lastDot = fileName.lastIndexOf('.');
            String fileExtension = lastDot > 0 ? fileName.substring(lastDot + 1).toLowerCase(Locale.ROOT) : "";

            if (!fileExtension.matches("jpg|jpeg|png|gif")) {
                userDAO.delete(createdUser.getUserId());
                request.setAttribute("error", "Only JPG, PNG, and GIF files are allowed.");
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }

            if (passportPhotoPart.getSize() > 5 * 1024 * 1024) {
                userDAO.delete(createdUser.getUserId());
                request.setAttribute("error", "Profile photo must not exceed 5MB.");
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }

            try (InputStream inputStream = passportPhotoPart.getInputStream()) {
                byte[] fileBytes = inputStream.readAllBytes();
                String uploadedUrl = CloudinaryUtil.uploadFile(fileBytes, fileName, CloudinaryUtil.getPassportFolder(), "image");
                if (uploadedUrl == null) {
                    userDAO.delete(createdUser.getUserId());
                    request.setAttribute("error", "Profile photo upload failed. Please try again.");
                    request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                    return;
                }
                passportPath = uploadedUrl;
            } catch (Exception e) {
                userDAO.delete(createdUser.getUserId());
                request.setAttribute("error", "Profile photo upload failed: " + e.getMessage());
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }
        }

        Student student = new Student();
        student.setUserId(createdUser.getUserId());
        String generatedReg = studentDAO.getNextRegNumber();
        student.setRegNumber(generatedReg);
        student.setCountry(country);
        student.setPassportPath(passportPath);
        
        // Set optional fields
        if (!isBlank(qualification)) student.setQualification(qualification);
        if (!isBlank(state)) student.setState(state);
        if (!isBlank(gender)) student.setGender(gender);
        if (!isBlank(emergencyContact)) student.setEmergencyContact(emergencyContact);
        
        // Parse Date of Birth if provided
        if (!isBlank(dob)) {
            try {
                student.setDob(java.time.LocalDate.parse(dob));
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to parse DOB", e);
            }
        }

        boolean studentCreated = studentDAO.create(student);
        if (!studentCreated) {
            if (passportPath != null && passportPath.startsWith("http")) {
                String uploadedPublicId = extractPublicIdFromUrl(passportPath);
                if (uploadedPublicId != null) {
                    CloudinaryUtil.deleteFile(uploadedPublicId, "image");
                }
            }
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
                LOGGER.log(Level.WARNING, "Failed to send registration email", e);
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

    private String extractPublicIdFromUrl(String url) {
        if (url == null || !url.contains("/upload/")) return null;

        String afterUpload = url.substring(url.indexOf("/upload/") + 8);
        if (afterUpload.contains("/")) {
            afterUpload = afterUpload.substring(afterUpload.indexOf("/") + 1);
        }

        int lastDot = afterUpload.lastIndexOf('.');
        if (lastDot > 0) {
            return afterUpload.substring(0, lastDot);
        }

        return afterUpload;
    }

    private boolean isAllowedGender(String gender) {
        return "Male".equalsIgnoreCase(gender) || "Female".equalsIgnoreCase(gender);
    }
}
