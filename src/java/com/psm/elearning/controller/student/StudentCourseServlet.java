package com.psm.elearning.controller.student;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.dao.UserDAO;
import com.psm.elearning.dao.UserDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.model.User;
import com.psm.elearning.model.Material;
import com.psm.elearning.util.SessionUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * StudentCourseServlet handles course browsing for students.
 * Actions: browse (list approved courses), details, search, filter
 */
public class StudentCourseServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(StudentCourseServlet.class.getName());
    
    private final CourseDAO courseDAO = new CourseDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate student session
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Student".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("user", session.getAttribute("user"));

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
        if (SessionUtil.resolveUserId(session) == null || !"Student".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.setAttribute("user", session.getAttribute("user"));

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
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);

            List<Integer> enrolledCourseIds = loadEnrolledCourseIds(userId);
            List<Course> courses = courseDAO.findByStatus("Approved");

            request.setAttribute("courses", courses);
            request.setAttribute("enrolledCourseIds", enrolledCourseIds);
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error browsing courses", e);
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
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);

            Integer courseId = parsePositiveInt(request.getParameter("id"));
            if (courseId == null) {
                request.setAttribute("errorMessage", "Invalid course ID");
                browseCourses(request, response);
                return;
            }
            Course course = courseDAO.findById(courseId);
            
            if (course == null) {
                request.setAttribute("errorMessage", "Course not found");
                browseCourses(request, response);
                return;
            }
            
            request.setAttribute("user", session.getAttribute("user"));

            List<Integer> enrolledCourseIds = loadEnrolledCourseIds(userId);
            request.setAttribute("enrolledCourseIds", enrolledCourseIds);

            // Load instructor details if available
            if (course.getCreatedBy() != null) {
                try {
                    User instructor = userDAO.findById(course.getCreatedBy());
                    if (instructor != null) {
                        request.setAttribute("instructor", instructor);
                    }
                } catch (Exception ex) {
                    LOGGER.log(Level.WARNING, "Failed to load instructor details", ex);
                }
            }

            List<Material> materials = materialDAO.findByCourse(courseId);
            request.setAttribute("materials", materials);
            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/student/course-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid course ID");
            browseCourses(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error viewing course details", e);
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
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);
            request.setAttribute("user", session.getAttribute("user"));
            
            String keyword = request.getParameter("keyword");
            
            if (keyword == null || keyword.trim().isEmpty()) {
                browseCourses(request, response);
                return;
            }
            
            List<Course> courses = courseDAO.searchCourses(keyword.trim());
            List<Integer> enrolledCourseIds = loadEnrolledCourseIds(userId);
            
            request.setAttribute("courses", courses);
            request.setAttribute("enrolledCourseIds", enrolledCourseIds);
            request.setAttribute("searchKeyword", keyword.trim());
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error searching courses", e);
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
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);
            request.setAttribute("user", session.getAttribute("user"));
            
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
            List<Integer> enrolledCourseIds = loadEnrolledCourseIds(userId);
            
            request.setAttribute("courses", courses);
            request.setAttribute("enrolledCourseIds", enrolledCourseIds);
            request.setAttribute("filterCategory", category);
            request.setAttribute("filterLevel", level);
            request.setAttribute("filterMinFee", minFee);
            request.setAttribute("filterMaxFee", maxFee);
            request.getRequestDispatcher("/WEB-INF/views/student/available-courses.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid fee range");
            browseCourses(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error filtering courses", e);
            request.setAttribute("errorMessage", "Filter failed");
            browseCourses(request, response);
        }
    }

    private List<Integer> loadEnrolledCourseIds(Integer userId) {
        try {
            List<com.psm.elearning.model.Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
            if (enrollments == null) return new ArrayList<>();
            return enrollments.stream().map(com.psm.elearning.model.Enrollment::getCourseId).collect(Collectors.toList());
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to load enrolled courses for user " + userId, e);
            return new ArrayList<>();
        }
    }

    private Integer parsePositiveInt(String value) {
        if (value == null) {
            return null;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

}
