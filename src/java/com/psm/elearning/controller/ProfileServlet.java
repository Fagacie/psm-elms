package com.psm.elearning.controller;

import com.psm.elearning.dao.StudentDAO;
import com.psm.elearning.dao.StudentDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.model.Student;
import com.psm.elearning.model.User;
import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ProfileServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAOImpl();
    private final StudentDAO studentDAO = new StudentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        
        // Get fresh data from database
        User user = userDAO.findById(userId);
        Student student = studentDAO.findByUserId(userId);
        
        if (user != null) {
            request.setAttribute("user", user);
        }
        if (student != null) {
            request.setAttribute("student", student);
        }
        
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        
        // Get form data
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String qualification = request.getParameter("qualification");
        String country = request.getParameter("country");
        String state = request.getParameter("state");
        String dobStr = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String emergencyContact = request.getParameter("emergencyContact");
        
        // Validate required fields
        if (fullName == null || fullName.trim().isEmpty()) {
            session.setAttribute("profileError", "Full name is required.");
            response.sendRedirect(request.getContextPath() + "/profile");
            return;
        }
        
        // Update User table
        User user = userDAO.findById(userId);
        if (user != null) {
            user.setFullName(fullName.trim());
            if (phone != null && !phone.trim().isEmpty()) {
                user.setPhone(phone.trim());
            }
            
            boolean userUpdated = userDAO.update(user);
            
            if (!userUpdated) {
                session.setAttribute("profileError", "Failed to update profile.");
                response.sendRedirect(request.getContextPath() + "/profile");
                return;
            }
            
            // Update session with new name
            session.setAttribute("userName", user.getFullName());
        }
        
        // Update Student table
        Student student = studentDAO.findByUserId(userId);
        if (student != null) {
            if (qualification != null) student.setQualification(qualification.trim());
            if (country != null) student.setCountry(country.trim());
            if (state != null) student.setState(state.trim());
            if (gender != null) student.setGender(gender.trim());
            if (emergencyContact != null) student.setEmergencyContact(emergencyContact.trim());
            
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                try {
                    student.setDob(LocalDate.parse(dobStr));
                } catch (Exception e) {
                    // Invalid date format, skip
                }
            }
            
            studentDAO.updateProfile(student);
            session.setAttribute("student", student);
        }
        
        session.setAttribute("profileSuccess", "Profile updated successfully!");
        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
