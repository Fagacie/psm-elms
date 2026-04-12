package com.psm.elearning.controller.admin;

import com.psm.elearning.dao.CourseDAO;
import com.psm.elearning.dao.CourseDAOImpl;
import com.psm.elearning.model.Course;
import com.psm.elearning.util.SessionUtil;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AdminCourseServlet handles course management for administrators.
 * Actions: list, approve, reject
 */
public class AdminCourseServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminCourseServlet.class.getName());
    
    private final CourseDAO courseDAO = new CourseDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate admin session
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list":
                listCourses(request, response);
                break;
            case "approve":
                approveCourse(request, response, session);
                break;
            case "reject":
                rejectCourse(request, response);
                break;
            case "archive":
                archiveCourse(request, response);
                break;
            case "restore":
                restoreCourse(request, response);
                break;
            default:
                listCourses(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Validate admin session
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null || !"Admin".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("approve".equals(action)) {
            approveCourse(request, response, session);
        } else if ("reject".equals(action)) {
            rejectCourse(request, response);
        } else if ("archive".equals(action)) {
            archiveCourse(request, response);
        } else if ("restore".equals(action)) {
            restoreCourse(request, response);
        } else {
            listCourses(request, response);
        }
    }

    /**
     * List all courses with optional status filter
     */
    private void listCourses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String statusFilter = request.getParameter("status");
            List<Course> courses;
            
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                courses = courseDAO.findByStatus(statusFilter);
            } else {
                courses = courseDAO.findAll();
            }
            
            if (courses == null) {
                courses = new java.util.ArrayList<>();
            }
            
            request.setAttribute("courses", courses);
            request.setAttribute("statusFilter", statusFilter);
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-courses.jsp").forward(request, response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error listing courses", e);
            
            request.setAttribute("errorMessage", "Failed to load courses: " + e.getMessage());
            request.setAttribute("courses", new java.util.ArrayList<>());
            
            try {
                request.getRequestDispatcher("/WEB-INF/views/admin/admin-courses.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading courses: " + e.getMessage());
            }
        }
    }

    /**
     * Approve a pending course
     */
    private void approveCourse(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        try {
            Integer courseId = parsePositiveInt(request.getParameter("id"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
                return;
            }
            Integer adminId = resolveUserId(session);
            
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notfound");
                return;
            }
            
            // Check if course is in pending status
            if (!Course.STATUS_PENDING.equals(course.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notpending");
                return;
            }
            
            boolean approved = courseDAO.approve(courseId, adminId);
            
            if (approved) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?success=approved");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=approvefailed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error approving course", e);
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=exception");
        }
    }

    /**
     * Reject a pending course (set to Archived)
     */
    private void rejectCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            Integer courseId = parsePositiveInt(request.getParameter("id"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
                return;
            }
            
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notfound");
                return;
            }
            
            // Check if course is in pending status
            if (!Course.STATUS_PENDING.equals(course.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notpending");
                return;
            }
            
            boolean rejected = courseDAO.reject(courseId);
            
            if (rejected) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?success=rejected");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=rejectfailed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error rejecting course", e);
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=exception");
        }
    }
    
    /**
     * Archive an approved course (disable it from being visible/enrollable)
     */
    private void archiveCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            Integer courseId = parsePositiveInt(request.getParameter("id"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
                return;
            }
            
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notfound");
                return;
            }
            
            // Check if course is approved (can only archive approved courses)
            if (!Course.STATUS_APPROVED.equals(course.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notapproved");
                return;
            }
            
            // Archive by setting status to Archived
            course.setStatus(Course.STATUS_ARCHIVED);
            boolean archived = courseDAO.update(course);
            
            if (archived) {
                LOGGER.log(Level.INFO, "[ADMIN] Course {0} archived", courseId);
                response.sendRedirect(request.getContextPath() + "/admin/courses?success=archived");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=archivefailed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error archiving course", e);
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=exception");
        }
    }
    
    /**
     * Restore an archived course back to approved status
     */
    private void restoreCourse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            Integer courseId = parsePositiveInt(request.getParameter("id"));
            if (courseId == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
                return;
            }
            
            Course course = courseDAO.findById(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notfound");
                return;
            }
            
            // Check if course is archived (can only restore archived courses)
            if (!Course.STATUS_ARCHIVED.equals(course.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=notarchived");
                return;
            }
            
            // Restore by setting status back to Approved
            course.setStatus(Course.STATUS_APPROVED);
            boolean restored = courseDAO.update(course);
            
            if (restored) {
                LOGGER.log(Level.INFO, "[ADMIN] Course {0} restored", courseId);
                response.sendRedirect(request.getContextPath() + "/admin/courses?success=restored");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?error=restorefailed");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error restoring course", e);
            response.sendRedirect(request.getContextPath() + "/admin/courses?error=exception");
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

    private Integer resolveUserId(HttpSession session) {
        if (session == null) return null;
        Object userId = session.getAttribute("userId");
        if (userId == null) return null;
        
        if (userId instanceof Integer) {
            int id = (Integer) userId;
            return id > 0 ? id : null;
        }
        
        if (userId instanceof String) {
            try {
                int id = Integer.parseInt((String) userId);
                return id > 0 ? id : null;
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) return null;
        Object role = session.getAttribute("userRole");
        if (role == null) role = session.getAttribute("role");
        if (role == null) return null;
        
        String roleStr = role.toString().trim();
        if ("Admin".equalsIgnoreCase(roleStr)) return "Admin";
        if ("Student".equalsIgnoreCase(roleStr)) return "Student";
        if ("Instructor".equalsIgnoreCase(roleStr)) return "Instructor";
        return null;
    }
}