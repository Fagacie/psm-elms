package com.psm.elearning.controller;

import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.model.User;
import com.psm.elearning.model.Course;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for the landing page with dynamic statistics
 */
public class LandingServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAOImpl();
        courseDAO = new CourseDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Fetch statistics
        int studentCount = userDAO.countByRole(User.ROLE_STUDENT);
        int instructorCount = userDAO.countByRole(User.ROLE_INSTRUCTOR);
        int courseCount = courseDAO.countByStatus(Course.STATUS_APPROVED);
        
        // Fetch all approved courses for dynamic client-side filtering/pagination
        List<Course> featuredCourses = courseDAO.findByStatus(Course.STATUS_APPROVED);
        
        // Set attributes for JSP
        request.setAttribute("studentCount", studentCount);
        request.setAttribute("instructorCount", instructorCount);
        request.setAttribute("courseCount", courseCount);
        request.setAttribute("featuredCourses", featuredCourses);
        
        // Forward to landing page JSP
        request.getRequestDispatcher("/WEB-INF/views/landing.jsp").forward(request, response);
    }
}
