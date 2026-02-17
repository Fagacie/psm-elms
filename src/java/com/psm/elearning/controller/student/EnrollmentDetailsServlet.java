package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.AssessmentRetakeRequestDAO;
import com.psm.elearning.dao.AssessmentRetakeRequestDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentSubmission;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Servlet to display enrollment details.
 */
public class EnrollmentDetailsServlet extends HttpServlet {
    
    private EnrollmentDAO enrollmentDAO;
    private MaterialDAO materialDAO;
    private PaymentDAO paymentDAO;
    private AssessmentDAO assessmentDAO;
    private AssessmentSubmissionDAO submissionDAO;
    private AssessmentRetakeRequestDAO retakeRequestDAO;
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        submissionDAO = new AssessmentSubmissionDAOImpl();
        retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (role == null) role = (String) session.getAttribute("userRole");
        if (!"Student".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = (Integer) session.getAttribute("userId");
            Integer enrollmentId = Integer.parseInt(request.getParameter("id"));
            
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }
            
            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
            if (payment != null) {
                enrollment.setPaymentStatus(payment.getStatus());
                enrollment.setPaymentRef(payment.getPaystackReference());
            }

            boolean paidAccess = "Paid".equalsIgnoreCase(enrollment.getPaymentStatus());
            List<Material> materials = new ArrayList<>();
            List<Assessment> assessments = new ArrayList<>();
            if (enrollment.getCourseId() != null) {
                materials = materialDAO.findByCourse(enrollment.getCourseId());
                assessments = assessmentDAO.findByCourse(enrollment.getCourseId());
                if (materials == null) materials = new ArrayList<>();
                if (assessments == null) assessments = new ArrayList<>();
            }

            Map<Integer, Integer> usedAttemptsByAssessment = new LinkedHashMap<>();
            Map<Integer, Integer> allowedAttemptsByAssessment = new LinkedHashMap<>();
            Map<Integer, AssessmentSubmission> latestSubmissionByAssessment = new LinkedHashMap<>();
            Map<Integer, Boolean> activeAttemptByAssessment = new LinkedHashMap<>();

            for (Assessment assessment : assessments) {
                List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
                int used = submissions != null ? submissions.size() : 0;
                int base = assessment.getMaxAttempts() != null && assessment.getMaxAttempts() > 0 ? assessment.getMaxAttempts() : 1;
                int allowed = base + retakeRequestDAO.countApproved(assessment.getAssessmentId(), userId);
                usedAttemptsByAssessment.put(assessment.getAssessmentId(), used);
                allowedAttemptsByAssessment.put(assessment.getAssessmentId(), allowed);
                latestSubmissionByAssessment.put(assessment.getAssessmentId(), (submissions != null && !submissions.isEmpty()) ? submissions.get(0) : null);

                Object attemptState = session.getAttribute("assessmentAttempt_" + assessment.getAssessmentId());
                activeAttemptByAssessment.put(assessment.getAssessmentId(), attemptState != null);
            }

            String tab = request.getParameter("tab");
            if (tab == null || tab.trim().isEmpty()) tab = "assessments";
            int progressPercent = resolveProgressPercent(enrollment.getCompletionStatus(), enrollment.getStatus());
            
            request.setAttribute("enrollment", enrollment);
            request.setAttribute("materials", materials);
            request.setAttribute("assessments", assessments);
            request.setAttribute("materialCount", materials.size());
            request.setAttribute("assessmentCount", assessments.size());
            request.setAttribute("paidAccess", paidAccess);
            request.setAttribute("activeTab", tab);
            request.setAttribute("progressPercent", progressPercent);
            request.setAttribute("usedAttemptsByAssessment", usedAttemptsByAssessment);
            request.setAttribute("allowedAttemptsByAssessment", allowedAttemptsByAssessment);
            request.setAttribute("latestSubmissionByAssessment", latestSubmissionByAssessment);
            request.setAttribute("activeAttemptByAssessment", activeAttemptByAssessment);
            request.getRequestDispatcher("/WEB-INF/views/student/enrollment-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            System.err.println("EnrollmentDetailsServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }

    private int resolveProgressPercent(String completionStatus, String status) {
        if ("Completed".equalsIgnoreCase(completionStatus) || "Completed".equalsIgnoreCase(status)) return 100;
        if ("In Progress".equalsIgnoreCase(completionStatus)) return 65;
        if ("Enrolled".equalsIgnoreCase(status) || "Active".equalsIgnoreCase(status)) return 25;
        return 0;
    }
}
