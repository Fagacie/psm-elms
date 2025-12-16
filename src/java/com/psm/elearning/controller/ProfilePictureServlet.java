package com.psm.elearning.controller;

import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;
import com.psm.elearning.util.CloudinaryUtil;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@MultipartConfig(maxFileSize = 5242880) // 5MB
public class ProfilePictureServlet extends HttpServlet {
    
    private final StudentDAO studentDAO = new StudentDAOImpl();
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("userRole");
        
        // Only students can upload passport photos
        if (!User.ROLE_STUDENT.equals(userRole)) {
            session.setAttribute("profileError", "Only students can upload passport photos.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        Part filePart = request.getPart("passportPhoto");
        
        if (filePart == null || filePart.getSize() == 0) {
            session.setAttribute("profileError", "Please select a file to upload.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Validate file type
        String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        if (!fileExtension.matches("jpg|jpeg|png|gif")) {
            session.setAttribute("profileError", "Only JPG, PNG, and GIF files are allowed.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }
        
        // Validate file size
        if (filePart.getSize() > MAX_FILE_SIZE) {
            session.setAttribute("profileError", "File size must not exceed 5MB.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }

        try {
            // Read file bytes
            byte[] fileBytes;
            try (InputStream inputStream = filePart.getInputStream()) {
                fileBytes = inputStream.readAllBytes();
            }

            // Upload to Cloudinary
            String folder = CloudinaryUtil.getPassportFolder();
            String cloudinaryUrl = CloudinaryUtil.uploadFile(fileBytes, fileName, folder, "image");
            
            if (cloudinaryUrl == null) {
                session.setAttribute("profileError", "Failed to upload image. Please try again.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }

            // Update database
            Student student = studentDAO.findByUserId(userId);
            
            if (student != null) {
                // Delete old Cloudinary image if exists
                String oldPath = student.getPassportPath();
                if (oldPath != null && oldPath.startsWith("http")) {
                    String oldPublicId = extractPublicIdFromUrl(oldPath);
                    if (oldPublicId != null) {
                        CloudinaryUtil.deleteFile(oldPublicId, "image");
                    }
                }
                
                student.setPassportPath(cloudinaryUrl);
                boolean updated = studentDAO.updateProfile(student);
                
                if (updated) {
                    session.setAttribute("student", student);
                    session.setAttribute("profileSuccess", "Profile picture uploaded successfully!");
                } else {
                    session.setAttribute("profileError", "Failed to save profile picture.");
                }
            } else {
                session.setAttribute("profileError", "Student record not found.");
            }
            
        } catch (Exception e) {
            session.setAttribute("profileError", "Error uploading file: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/profile");
    }
    
    private String extractPublicIdFromUrl(String url) {
        if (url == null || !url.contains("/upload/")) return null;
        
        String afterUpload = url.substring(url.indexOf("/upload/") + 8);
        if (afterUpload.contains("/")) {
            afterUpload = afterUpload.substring(afterUpload.indexOf("/") + 1);
        }
        
        int lastDot = afterUpload.lastIndexOf(".");
        if (lastDot > 0) {
            return afterUpload.substring(0, lastDot);
        }
        
        return afterUpload;
    }
}

