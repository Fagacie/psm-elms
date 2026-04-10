package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.service.EnrollmentStateSyncService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to display student's enrollments.
 */
public class MyEnrollmentsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MyEnrollmentsServlet.class.getName());
    
    private EnrollmentDAO enrollmentDAO;
    private PaymentDAO paymentDAO;
    private MaterialDAO materialDAO;
    private AssessmentDAO assessmentDAO;
    private EnrollmentStateSyncService enrollmentStateSyncService;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        enrollmentStateSyncService = new EnrollmentStateSyncService();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = resolveRole(session);
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = resolveUserId(session);
            
            // Get all enrollments for this student
            List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
            if (enrollments == null) enrollments = new ArrayList<>();
            int inProgressCount = 0;
            int completedCount = 0;
            int paidCount = 0;
            Map<Integer, Integer> materialCountByCourse = new HashMap<>();
            Map<Integer, Integer> assessmentCountByCourse = new HashMap<>();

            // Enrich each enrollment with latest payment status/reference
            for (Enrollment e : enrollments) {
                enrollmentStateSyncService.syncEnrollmentState(e);
                Payment p = paymentDAO.getPaymentByEnrollmentId(e.getEnrollmentId());
                if (p != null) {
                    e.setPaymentStatus(p.getStatus());
                    e.setPaymentRef(p.getPaystackReference());
                } else {
                    e.setPaymentStatus("Pending");
                }

                if (isPaymentComplete(e.getPaymentStatus())) {
                    paidCount++;
                }
                if ("Completed".equalsIgnoreCase(e.getCompletionStatus()) || "Completed".equalsIgnoreCase(e.getStatus())) {
                    completedCount++;
                } else if ("In Progress".equalsIgnoreCase(e.getCompletionStatus())
                        || "Active".equalsIgnoreCase(e.getStatus())
                        || "Enrolled".equalsIgnoreCase(e.getStatus())) {
                    inProgressCount++;
                }

                if (e.getCourseId() != null && !materialCountByCourse.containsKey(e.getCourseId())) {
                    List<Material> materials = materialDAO.findByCourse(e.getCourseId());
                    List<Assessment> assessments = assessmentDAO.findByCourse(e.getCourseId());
                    materialCountByCourse.put(e.getCourseId(), materials != null ? materials.size() : 0);
                    assessmentCountByCourse.put(e.getCourseId(), assessments != null ? assessments.size() : 0);
                }
            }
            
            request.setAttribute("enrollments", enrollments);
            request.setAttribute("inProgressCount", inProgressCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("paidCount", paidCount);
            request.setAttribute("materialCountByCourse", materialCountByCourse);
            request.setAttribute("assessmentCountByCourse", assessmentCountByCourse);
            request.getRequestDispatcher("/WEB-INF/views/student/my-enrollments.jsp").forward(request, response);
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "MyEnrollmentsServlet failed to load enrollments", e);
            response.sendRedirect(request.getContextPath() + "/dashboard?error=exception");
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

    private boolean isPaymentComplete(String paymentStatus) {
        if (paymentStatus == null) {
            return false;
        }
        String normalized = paymentStatus.trim().toLowerCase(Locale.ENGLISH);
        return "paid".equals(normalized)
                || "completed".equals(normalized)
                || "success".equals(normalized);
    }
}
