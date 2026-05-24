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
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
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

/**
 * AJAX endpoint to mark a material as completed/viewed.
 * Used by both Learning Hub and material-viewer.jsp.
 * Returns full progress data so the UI can update without a page reload.
 */
public class MarkMaterialCompleteServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(MarkMaterialCompleteServlet.class.getName());

    private MaterialProgressDAO materialProgressDAO;
    private EnrollmentDAO enrollmentDAO;
    private MaterialDAO materialDAO;
    private AssessmentDAO assessmentDAO;
    private AssessmentSubmissionDAO submissionDAO;
    private EnrollmentStateSyncService enrollmentStateSyncService;

    @Override
    public void init() throws ServletException {
        super.init();
        materialProgressDAO = new MaterialProgressDAOImpl();
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        submissionDAO = new AssessmentSubmissionDAOImpl();
        enrollmentStateSyncService = new EnrollmentStateSyncService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            Integer userId = SessionUtil.resolveUserId(session);
            String role = SessionUtil.resolveRole(session);

            if (userId == null || role == null || !"Student".equalsIgnoreCase(role)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
                return;
            }

            String materialIdParam = request.getParameter("materialId");
            String enrollmentIdParam = request.getParameter("enrollmentId");

            if (materialIdParam == null || enrollmentIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Missing parameters\"}");
                return;
            }

            int materialId;
            int enrollmentId;
            try {
                materialId = Integer.parseInt(materialIdParam.trim());
                enrollmentId = Integer.parseInt(enrollmentIdParam.trim());
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Invalid parameters\"}");
                return;
            }

            // Verify enrollment ownership
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            if (enrollment == null || !enrollment.getUserId().equals(userId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"Unauthorized enrollment access\"}");
                return;
            }

            // Verify material belongs to enrollment's course
            Material material = materialDAO.findById(materialId);
            if (material == null || material.getCourseId() == null
                    || enrollment.getCourseId() == null
                    || !enrollment.getCourseId().equals(material.getCourseId())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Material does not belong to this enrollment\"}");
                return;
            }

            // Check course expiry
            if (enrollment.getDaysRemaining() < 0
                    && enrollment.getCourseDuration() != null
                    && enrollment.getCourseDuration() > 0) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.print("{\"success\":false,\"message\":\"Course has expired. Progress is read-only.\"}");
                return;
            }

            boolean success = materialProgressDAO.markCompleted(userId, materialId, material.getCourseId());
            if (!success) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"Failed to update material progress\"}");
                return;
            }

            // Sync enrollment state to get accurate progress
            EnrollmentStateSyncService.SyncResult syncResult = null;
            try {
                syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
            } catch (Exception syncEx) {
                LOGGER.warning("MarkMaterialCompleteServlet: sync failed: " + syncEx.getMessage());
            }

            int progressPercent = syncResult != null
                    ? syncResult.getProgressPercent()
                    : calculateFallbackProgress(userId, material.getCourseId());
            int viewedMaterials = syncResult != null
                    ? syncResult.getViewedMaterials()
                    : materialProgressDAO.countViewedByCourse(userId, material.getCourseId());
            int totalMaterials = syncResult != null
                    ? syncResult.getTotalMaterials()
                    : materialDAO.findByCourse(material.getCourseId()).size();

            // Build continue navigation
            String continueLabel;
            String continueUrl;
            Material next = getNextUncompletedMaterial(userId, material.getCourseId());
            if (next != null) {
                continueLabel = "Continue Learning";
                continueUrl = request.getContextPath()
                        + "/student/materials?action=preview&id=" + next.getMaterialId()
                        + "&enrollmentId=" + enrollmentId;
            } else {
                Assessment nextAssessment = getNextUnpassedAssessment(userId, material.getCourseId());
                if (nextAssessment != null) {
                    continueLabel = "Start Assessment";
                    continueUrl = request.getContextPath()
                            + "/student/assessments?action=start&courseId=" + material.getCourseId()
                            + "&assessmentId=" + nextAssessment.getAssessmentId()
                            + "&fromHub=1&enrollmentId=" + enrollmentId;
                } else {
                    continueLabel = "Back to Course";
                    continueUrl = request.getContextPath()
                            + "/student/enrollment-details?id=" + enrollmentId;
                }
            }

            out.print("{\"success\":true"
                    + ",\"message\":\"Material marked as completed\""
                    + ",\"progressPercent\":" + progressPercent
                    + ",\"viewedMaterials\":" + viewedMaterials
                    + ",\"totalMaterials\":" + totalMaterials
                    + ",\"status\":\"completed\""
                    + ",\"continueLabel\":\"" + escapeJson(continueLabel) + "\""
                    + ",\"continueUrl\":\"" + escapeJson(continueUrl) + "\""
                    + "}");

        } catch (Exception e) {
            LOGGER.severe("MarkMaterialCompleteServlet error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Server error\"}");
        } finally {
            out.flush();
            out.close();
        }
    }

    private int calculateFallbackProgress(int userId, int courseId) {
        List<Material> materials = materialDAO.findByCourse(courseId);
        int total = materials != null ? materials.size() : 0;
        if (total <= 0) return 0;
        int viewed = materialProgressDAO.countViewedByCourse(userId, courseId);
        return (int) Math.round((viewed * 100.0) / total);
    }

    private Material getNextUncompletedMaterial(int userId, int courseId) {
        List<Material> materials = materialDAO.findByCourse(courseId);
        if (materials == null || materials.isEmpty()) return null;
        materials.sort((a, b) -> {
            Integer ao = a.getDisplayOrder() != null ? a.getDisplayOrder() : Integer.MAX_VALUE;
            Integer bo = b.getDisplayOrder() != null ? b.getDisplayOrder() : Integer.MAX_VALUE;
            return ao.equals(bo)
                    ? Comparator.<Integer>nullsLast(Integer::compareTo).compare(a.getMaterialId(), b.getMaterialId())
                    : ao.compareTo(bo);
        });
        Set<Integer> completed = materialProgressDAO.findViewedMaterialIdsByCourse(userId, courseId);
        for (Material m : materials) {
            if (m.getMaterialId() != null && !completed.contains(m.getMaterialId())) {
                return m;
            }
        }
        return null;
    }

    private Assessment getNextUnpassedAssessment(int userId, int courseId) {
        List<Assessment> assessments = assessmentDAO.findByCourse(courseId);
        if (assessments == null) return null;
        for (Assessment a : assessments) {
            List<AssessmentSubmission> subs = submissionDAO.findByAssessmentAndUser(a.getAssessmentId(), userId);
            if (!EnrollmentStateSyncService.resolveAssessmentProgress(a, subs).isPassed()) {
                return a;
            }
        }
        return null;
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
