package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.model.Course;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * StudentCourseServlet handles course browsing for students.
 * Actions: browse (list approved courses), details, search, filter
 */
public class StudentCourseServlet extends HttpServlet {
    
    private final CourseDAO courseDAO = new CourseDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate student session
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "browse";

        switch (action) {
            case "browse":
                browseCourses(request, response);
                break;
            case "details":
                viewCourseDetails(request, response);
                break;
            case "search":
                searchCourses(request, response);
                break;
            case "filter":
                filterCourses(request, response);
                break;
            default:
                browseCourses(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate student session
        HttpSession session = request.getSession(false);
        if (session == null || !"Student".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("search".equals(action)) {
            searchCourses(request, response);
        } else if ("filter".equals(action)) {
            filterCourses(request, response);
        } else {
            browseCourses(request, response);
        }
    }

    /**
     * Browse all approved courses
     */
    private void browseCourses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get all courses (Status column doesn't exist in current schema)
            List<Course> courses = courseDAO.findAll();
            
            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error browsing courses: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to load courses");
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        }
    }

    /**
     * View detailed information about a specific course
     */
    private void viewCourseDetails(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int courseId = Integer.parseInt(request.getParameter("id"));
            Course course = courseDAO.findById(courseId);
            
            if (course == null) {
                request.setAttribute("errorMessage", "Course not found");
                browseCourses(request, response);
                return;
            }
            
            // Status check removed - showing all courses
            
            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/student/course-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid course ID");
            browseCourses(request, response);
        } catch (Exception e) {
            System.err.println("Error viewing course details: " + e.getMessage());
            request.setAttribute("errorMessage", "An error occurred");
            browseCourses(request, response);
        }
    }

    /**
     * Search courses by keyword
     */
    private void searchCourses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String keyword = request.getParameter("keyword");
            
            if (keyword == null || keyword.trim().isEmpty()) {
                browseCourses(request, response);
                return;
            }
            
            List<Course> courses = courseDAO.searchCourses(keyword.trim());
            
            request.setAttribute("courses", courses);
            request.setAttribute("searchKeyword", keyword.trim());
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("Error searching courses: " + e.getMessage());
            request.setAttribute("errorMessage", "Search failed");
            browseCourses(request, response);
        }
    }

    /**
     * Filter courses by category, level, and fee range
     */
    private void filterCourses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String category = request.getParameter("category");
            String level = request.getParameter("level");
            String minFeeStr = request.getParameter("minFee");
            String maxFeeStr = request.getParameter("maxFee");
            
            Double minFee = null;
            Double maxFee = null;
            
            if (minFeeStr != null && !minFeeStr.trim().isEmpty()) {
                minFee = Double.parseDouble(minFeeStr);
            }
            if (maxFeeStr != null && !maxFeeStr.trim().isEmpty()) {
                maxFee = Double.parseDouble(maxFeeStr);
            }
            
            List<Course> courses = courseDAO.filterCourses(category, level, minFee, maxFee);
            
            request.setAttribute("courses", courses);
            request.setAttribute("filterCategory", category);
            request.setAttribute("filterLevel", level);
            request.setAttribute("filterMinFee", minFee);
            request.setAttribute("filterMaxFee", maxFee);
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid fee range");
            browseCourses(request, response);
        } catch (Exception e) {
            System.err.println("Error filtering courses: " + e.getMessage());
            request.setAttribute("errorMessage", "Filter failed");
            browseCourses(request, response);
        }
    }
}
