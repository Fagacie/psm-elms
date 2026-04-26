package com.psm.elearning.controller.student;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAOImpl;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Payment;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.SessionUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

public class MarkMaterialCompletedServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MarkMaterialCompletedServlet.class.getName());

    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAOImpl();
    private final MaterialDAO materialDAO = new MaterialDAOImpl();
    private final MaterialProgressDAO materialProgressDAO = new MaterialProgressDAOImpl();
    private final PaymentDAO paymentDAO = new PaymentDAOImpl();
    private final AssessmentDAO assessmentDAO = new AssessmentDAOImpl();
    private final AssessmentSubmissionDAO submissionDAO = new AssessmentSubmissionDAOImpl();
    private final EnrollmentStateSyncService enrollmentStateSyncService = new EnrollmentStateSyncService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);
            String role = SessionUtil.resolveRole(session);
            if (userId == null || role == null || !"Student".equalsIgnoreCase(role)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
                return;
            }

            Integer materialId = parseInt(request.getParameter("materialId"));
            if (materialId == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid materialId\"}");
                return;
            }

            Material material = materialDAO.findById(materialId);
            if (material == null || material.getCourseId() == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Material not found\"}");
                return;
            }

            Enrollment enrollment = checkEnrollment(userId, material.getCourseId());
            if (enrollment == null) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"No enrollment or course access\"}");
                return;
            }

            boolean completed = markCompleted(userId, material.getMaterialId(), material.getCourseId());
            if (!completed) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to save completion\"}");
                return;
            }

            EnrollmentStateSyncService.SyncResult syncResult = syncProgress(userId, material.getCourseId());
            int progressPercent = syncResult != null
                    ? syncResult.getProgressPercent()
                    : calculateProgress(userId, material.getCourseId());
            int viewedMaterials = syncResult != null ? syncResult.getViewedMaterials() : materialProgressDAO.countViewedByCourse(userId, material.getCourseId());
            List<Material> courseMaterials = syncResult == null ? materialDAO.findByCourse(material.getCourseId()) : null;
            int totalMaterials = syncResult != null ? syncResult.getTotalMaterials() : (courseMaterials != null ? courseMaterials.size() : 0);
            Material next = getNextMaterial(userId, material.getCourseId());
            String continueLabel;
            String continueUrl;

            if (next != null) {
                continueLabel = "Continue Learning";
                continueUrl = request.getContextPath() + "/student/materials?action=preview&id=" + next.getMaterialId() + "&enrollmentId=" + enrollment.getEnrollmentId();
            } else {
                Assessment nextAssessment = getNextAssessment(userId, material.getCourseId());
                if (nextAssessment != null) {
                    continueLabel = "Start Assessment";
                    continueUrl = request.getContextPath() + "/student/assessments?action=start&courseId=" + material.getCourseId() + "&assessmentId=" + nextAssessment.getAssessmentId() + "&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                } else {
                    continueLabel = "Open Certificates";
                    continueUrl = request.getContextPath() + "/student/certificates";
                }
            }

            out.print("{\"success\":true,\"message\":\"Material marked completed\",\"progressPercent\":" + progressPercent +
                    ",\"viewedMaterials\":" + viewedMaterials +
                    ",\"totalMaterials\":" + totalMaterials +
                    ",\"status\":\"completed\"" +
                    ",\"continueLabel\":\"" + escapeJson(continueLabel) + "\",\"continueUrl\":\"" + escapeJson(continueUrl) + "\"}");

        } catch (Exception ex) {
            LOGGER.severe("MarkMaterialCompletedServlet failed: " + ex.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            out.flush();
            out.close();
        }
    }

    private Enrollment checkEnrollment(Integer userId, Integer courseId) {
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments == null) {
            return null;
        }
        for (Enrollment enrollment : enrollments) {
            if (hasEnrollmentAccess(enrollment, courseId)) {
                return enrollment;
            }
        }
        return null;
    }

    private boolean hasEnrollmentAccess(Enrollment enrollment, Integer courseId) {
        if (enrollment == null || courseId == null) {
            return false;
        }
        if (enrollment.getCourseId() == null || !enrollment.getCourseId().equals(courseId)) {
            return false;
        }
        if (isFreeEnrollment(enrollment)) {
            return true;
        }
        if (enrollment.getEnrollmentId() == null) {
            return false;
        }
        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        if (payment != null && isPaymentComplete(payment.getStatus())) {
            return true;
        }
        return isPaymentComplete(enrollment.getPaymentStatus());
    }

    private boolean isFreeEnrollment(Enrollment enrollment) {
        return enrollment != null
                && enrollment.getCoursePrice() != null
                && enrollment.getCoursePrice() <= 0.0;
    }

    private boolean markCompleted(Integer userId, Integer materialId, Integer courseId) {
        return materialProgressDAO.markCompleted(userId, materialId, courseId);
    }

    private int calculateProgress(Integer userId, Integer courseId) {
        EnrollmentStateSyncService.SyncResult syncResult = syncProgress(userId, courseId);
        if (syncResult != null) {
            return syncResult.getProgressPercent();
        }

        List<Material> materials = materialDAO.findByCourse(courseId);
        int total = materials != null ? materials.size() : 0;
        if (total <= 0) {
            return 0;
        }
        int completed = materialProgressDAO.countViewedByCourse(userId, courseId);
        return (int) Math.round((completed * 100.0) / total);
    }

    private EnrollmentStateSyncService.SyncResult syncProgress(Integer userId, Integer courseId) {
        Enrollment enrollment = null;
        List<Enrollment> enrollments = enrollmentDAO.getEnrollmentsByStudent(userId);
        if (enrollments != null) {
            for (Enrollment candidate : enrollments) {
                if (candidate.getCourseId() != null && candidate.getCourseId().equals(courseId)) {
                    enrollment = candidate;
                    break;
                }
            }
        }
        return enrollment != null ? enrollmentStateSyncService.syncEnrollmentState(enrollment) : null;
    }

    private Material getNextMaterial(Integer userId, Integer courseId) {
        List<Material> materials = materialDAO.findByCourse(courseId);
        if (materials == null || materials.isEmpty()) {
            return null;
        }
        materials.sort((a, b) -> {
            Integer ao = a.getDisplayOrder() != null ? a.getDisplayOrder() : Integer.MAX_VALUE;
            Integer bo = b.getDisplayOrder() != null ? b.getDisplayOrder() : Integer.MAX_VALUE;
            if (!ao.equals(bo)) {
                return ao.compareTo(bo);
            }
            return Comparator.nullsLast(Integer::compareTo).compare(a.getMaterialId(), b.getMaterialId());
        });

        Set<Integer> completed = materialProgressDAO.findViewedMaterialIdsByCourse(userId, courseId);
        for (Material material : materials) {
            if (material.getMaterialId() != null && !completed.contains(material.getMaterialId())) {
                return material;
            }
        }
        return null;
    }

    private Assessment getNextAssessment(Integer userId, Integer courseId) {
        List<Assessment> assessments = assessmentDAO.findByCourse(courseId);
        if (assessments == null) {
            return null;
        }
        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
            EnrollmentStateSyncService.AssessmentProgressState progressState = EnrollmentStateSyncService.resolveAssessmentProgress(assessment, submissions);
            if (!progressState.isPassed()) {
                return assessment;
            }
        }
        return null;
    }

    private boolean isPaymentComplete(String paymentStatus) {
        if (paymentStatus == null) {
            return false;
        }
        String normalized = paymentStatus.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
