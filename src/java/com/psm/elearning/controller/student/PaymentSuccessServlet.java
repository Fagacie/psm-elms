package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.model.Enrollment;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet to display payment success page.
 */
public class PaymentSuccessServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Integer userId = resolveUserId(session);
        if (session == null || userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = resolveRole(session);
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer enrollmentId = parseEnrollmentId(request.getParameter("enrollmentId"));
            if (enrollmentId == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }
            if (enrollment.getUserId() == null || !enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }
            
            request.setAttribute("enrollment", enrollment);
            request.getRequestDispatcher("/WEB-INF/views/student/payment-success.jsp").forward(request, response);
            
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments");
        }
    }

    private Integer parseEnrollmentId(String value) {
        if (value == null) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object raw = session.getAttribute("userId");
        if (raw instanceof Integer) {
            Integer parsed = (Integer) raw;
            return parsed > 0 ? parsed : null;
        }
        if (raw instanceof String) {
            try {
                int parsed = Integer.parseInt(((String) raw).trim());
                return parsed > 0 ? parsed : null;
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String resolveRole(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object role = session.getAttribute("role");
        if (!(role instanceof String) || ((String) role).trim().isEmpty()) {
            role = session.getAttribute("userRole");
        }
        if (!(role instanceof String)) {
            return null;
        }
        String normalized = ((String) role).trim();
        if ("Student".equalsIgnoreCase(normalized)) {
            return "Student";
        }
        if ("Admin".equalsIgnoreCase(normalized)) {
            return "Admin";
        }
        if ("Instructor".equalsIgnoreCase(normalized)) {
            return "Instructor";
        }
        return null;
    }
}
