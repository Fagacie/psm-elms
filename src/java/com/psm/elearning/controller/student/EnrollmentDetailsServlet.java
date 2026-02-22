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
import com.psm.elearning.dao.MaterialProgressDAO;
import com.psm.elearning.dao.MaterialProgressDAOImpl;
import com.psm.elearning.model.Enrollment;
import com.psm.elearning.model.Material;
import com.psm.elearning.model.Payment;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.service.EnrollmentStateSyncService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
    private MaterialProgressDAO materialProgressDAO;
    private EnrollmentStateSyncService enrollmentStateSyncService;

    public static class LearningItem {
        private final int order;
        private final String type;
        private final String iconClass;
        private final String title;
        private final String description;
        private final String badgeText;
        private final String badgeClass;
        private final String metaPrimary;
        private final String metaSecondary;
        private final String metaTertiary;
        private final String statusLabel;
        private final String statusClass;
        private final boolean locked;
        private final String lockReason;
        private final String primaryActionLabel;
        private final String primaryActionUrl;
        private final String primaryActionIcon;
        private final String secondaryActionLabel;
        private final String secondaryActionUrl;
        private final String secondaryActionIcon;

        private LearningItem(int order,
                             String type,
                             String iconClass,
                             String title,
                             String description,
                             String badgeText,
                             String badgeClass,
                             String metaPrimary,
                             String metaSecondary,
                             String metaTertiary,
                             String statusLabel,
                             String statusClass,
                             boolean locked,
                             String lockReason,
                             String primaryActionLabel,
                             String primaryActionUrl,
                             String primaryActionIcon,
                             String secondaryActionLabel,
                             String secondaryActionUrl,
                             String secondaryActionIcon) {
            this.order = order;
            this.type = type;
            this.iconClass = iconClass;
            this.title = title;
            this.description = description;
            this.badgeText = badgeText;
            this.badgeClass = badgeClass;
            this.metaPrimary = metaPrimary;
            this.metaSecondary = metaSecondary;
            this.metaTertiary = metaTertiary;
            this.statusLabel = statusLabel;
            this.statusClass = statusClass;
            this.locked = locked;
            this.lockReason = lockReason;
            this.primaryActionLabel = primaryActionLabel;
            this.primaryActionUrl = primaryActionUrl;
            this.primaryActionIcon = primaryActionIcon;
            this.secondaryActionLabel = secondaryActionLabel;
            this.secondaryActionUrl = secondaryActionUrl;
            this.secondaryActionIcon = secondaryActionIcon;
        }

        public int getOrder() { return order; }
        public String getType() { return type; }
        public String getIconClass() { return iconClass; }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public String getBadgeText() { return badgeText; }
        public String getBadgeClass() { return badgeClass; }
        public String getMetaPrimary() { return metaPrimary; }
        public String getMetaSecondary() { return metaSecondary; }
        public String getMetaTertiary() { return metaTertiary; }
        public String getStatusLabel() { return statusLabel; }
        public String getStatusClass() { return statusClass; }
        public boolean isLocked() { return locked; }
        public String getLockReason() { return lockReason; }
        public String getPrimaryActionLabel() { return primaryActionLabel; }
        public String getPrimaryActionUrl() { return primaryActionUrl; }
        public String getPrimaryActionIcon() { return primaryActionIcon; }
        public String getSecondaryActionLabel() { return secondaryActionLabel; }
        public String getSecondaryActionUrl() { return secondaryActionUrl; }
        public String getSecondaryActionIcon() { return secondaryActionIcon; }
    }
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
        submissionDAO = new AssessmentSubmissionDAOImpl();
        retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
        materialProgressDAO = new MaterialProgressDAOImpl();
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

            List<LearningItem> learningItems = new ArrayList<>();
            List<Material> orderedMaterials = new ArrayList<>(materials);
            orderedMaterials.sort((a, b) -> {
                Integer ao = a.getDisplayOrder() != null ? a.getDisplayOrder() : Integer.MAX_VALUE;
                Integer bo = b.getDisplayOrder() != null ? b.getDisplayOrder() : Integer.MAX_VALUE;
                int cmp = ao.compareTo(bo);
                if (cmp != 0) return cmp;
                if (a.getUploadDate() == null && b.getUploadDate() == null) return 0;
                if (a.getUploadDate() == null) return 1;
                if (b.getUploadDate() == null) return -1;
                return a.getUploadDate().compareTo(b.getUploadDate());
            });

            Set<Integer> materialIds = new HashSet<>();
            for (Material material : orderedMaterials) {
                materialIds.add(material.getMaterialId());
            }

            Map<Integer, List<Assessment>> assessmentsAfterMaterial = new LinkedHashMap<>();
            List<Assessment> finalAssessments = new ArrayList<>();

            for (Assessment assessment : assessments) {
                AssessmentPlacementUtil.Placement placement = AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
                assessment.setInstructions(AssessmentPlacementUtil.stripPlacement(assessment.getInstructions()));
                if ("afterMaterial".equals(placement.type)
                        && placement.materialId != null
                        && materialIds.contains(placement.materialId)) {
                    assessmentsAfterMaterial
                            .computeIfAbsent(placement.materialId, key -> new ArrayList<>())
                            .add(assessment);
                } else {
                    finalAssessments.add(assessment);
                }
            }

            for (List<Assessment> list : assessmentsAfterMaterial.values()) {
                list.sort((a, b) -> {
                    if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                    if (a.getCreatedAt() == null) return 1;
                    if (b.getCreatedAt() == null) return -1;
                    return a.getCreatedAt().compareTo(b.getCreatedAt());
                });
            }
            finalAssessments.sort((a, b) -> {
                if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                if (a.getCreatedAt() == null) return 1;
                if (b.getCreatedAt() == null) return -1;
                return a.getCreatedAt().compareTo(b.getCreatedAt());
            });

            int orderIndex = 1;
            for (Material material : orderedMaterials) {
                String iconClass = resolveMaterialIcon(material.getMaterialType());
                String badgeText = material.getMaterialType();
                String metaPrimary = material.getDisplayOrder() != null ? "Chapter " + material.getDisplayOrder() : "Material";
                String metaSecondary = material.getUploadDate() != null ? material.getUploadDate().toLocalDate().toString() : "";
                String statusLabel = paidAccess ? "Available" : "Locked";
                String statusClass = paidAccess ? "status-Approved" : "status-Pending";
                String lockReason = paidAccess ? "" : "Payment required to access this material";
                String primaryLabel = "Open";
                String primaryIcon = "fa-eye";
                if ("Link".equalsIgnoreCase(material.getMaterialType())) {
                    primaryLabel = "Open Link";
                    primaryIcon = "fa-link";
                }
                String primaryUrl = paidAccess
                        ? request.getContextPath() + "/student/materials?action=view&id=" + material.getMaterialId()
                        : null;
                String secondaryLabel = !"Link".equalsIgnoreCase(material.getMaterialType()) ? "Download" : null;
                String secondaryIcon = secondaryLabel != null ? "fa-download" : null;
                String secondaryUrl = (paidAccess && secondaryLabel != null)
                        ? request.getContextPath() + "/student/materials?action=download&id=" + material.getMaterialId()
                        : null;
                learningItems.add(new LearningItem(
                        orderIndex++,
                        "Material",
                        iconClass,
                        material.getTitle(),
                        material.getDescription(),
                        badgeText,
                        "learning-badge",
                        metaPrimary,
                        metaSecondary,
                        null,
                        statusLabel,
                        statusClass,
                        !paidAccess,
                        lockReason,
                        primaryLabel,
                        primaryUrl,
                        primaryIcon,
                        secondaryLabel,
                        secondaryUrl,
                        secondaryIcon
                ));

                List<Assessment> tiedAssessments = assessmentsAfterMaterial.getOrDefault(material.getMaterialId(), new ArrayList<>());
                for (Assessment assessment : tiedAssessments) {
                    int used = usedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                    int allowed = allowedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                    AssessmentSubmission latest = latestSubmissionByAssessment.get(assessment.getAssessmentId());
                    boolean hasActiveAttempt = activeAttemptByAssessment.getOrDefault(assessment.getAssessmentId(), false);
                    String assessmentStatusLabel;
                    String assessmentStatusClass;
                    if (!paidAccess) {
                        assessmentStatusLabel = "Locked";
                        assessmentStatusClass = "status-Pending";
                    } else if (hasActiveAttempt) {
                        assessmentStatusLabel = "In Progress";
                        assessmentStatusClass = "status-Pending";
                    } else if (latest != null) {
                        assessmentStatusLabel = "Completed";
                        assessmentStatusClass = "status-Approved";
                    } else {
                        assessmentStatusLabel = "Not Started";
                        assessmentStatusClass = "status-Archived";
                    }
                    String iconClassAssessment = resolveAssessmentIcon(assessment.getType());
                    String metaPrimaryAssessment = (assessment.getDuration() != null ? assessment.getDuration() : 30) + " min";
                    String metaSecondaryAssessment = "Attempts: " + used + " / " + Math.max(allowed, 1);
                    String metaTertiaryAssessment = latest != null && latest.getScore() != null ? "Score: " + latest.getScore() : "";
                    String lockReasonAssessment = paidAccess ? "" : "Payment required to take assessments";
                    String primaryLabelAssessment = null;
                    String primaryUrlAssessment = null;
                    String primaryIconAssessment = null;
                    if (paidAccess && hasActiveAttempt) {
                        primaryLabelAssessment = "Continue";
                        primaryUrlAssessment = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&mode=attempt&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                        primaryIconAssessment = "fa-play";
                    } else if (paidAccess && used < Math.max(allowed, 1)) {
                        primaryLabelAssessment = "Start";
                        primaryUrlAssessment = request.getContextPath() + "/student/assessments?action=start&courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                        primaryIconAssessment = "fa-play";
                    }
                    String secondaryLabelAssessment = "Details";
                    String secondaryUrlAssessment = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                    String secondaryIconAssessment = "fa-info-circle";
                    learningItems.add(new LearningItem(
                            orderIndex++,
                            "Assessment",
                            iconClassAssessment,
                            assessment.getTitle(),
                            assessment.getInstructions(),
                            assessment.getType(),
                            "learning-badge",
                            metaPrimaryAssessment,
                            metaSecondaryAssessment,
                            metaTertiaryAssessment,
                            assessmentStatusLabel,
                            assessmentStatusClass,
                            !paidAccess,
                            lockReasonAssessment,
                            primaryLabelAssessment,
                            primaryUrlAssessment,
                            primaryIconAssessment,
                            secondaryLabelAssessment,
                            secondaryUrlAssessment,
                            secondaryIconAssessment
                    ));
                }
            }

            for (Assessment assessment : finalAssessments) {
                int used = usedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                int allowed = allowedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                AssessmentSubmission latest = latestSubmissionByAssessment.get(assessment.getAssessmentId());
                boolean hasActiveAttempt = activeAttemptByAssessment.getOrDefault(assessment.getAssessmentId(), false);
                String statusLabel;
                String statusClass;
                if (!paidAccess) {
                    statusLabel = "Locked";
                    statusClass = "status-Pending";
                } else if (hasActiveAttempt) {
                    statusLabel = "In Progress";
                    statusClass = "status-Pending";
                } else if (latest != null) {
                    statusLabel = "Completed";
                    statusClass = "status-Approved";
                } else {
                    statusLabel = "Not Started";
                    statusClass = "status-Archived";
                }
                String iconClass = resolveAssessmentIcon(assessment.getType());
                String metaPrimary = (assessment.getDuration() != null ? assessment.getDuration() : 30) + " min";
                String metaSecondary = "Attempts: " + used + " / " + Math.max(allowed, 1);
                String metaTertiary = latest != null && latest.getScore() != null ? "Score: " + latest.getScore() : "";
                String lockReason = paidAccess ? "" : "Payment required to take assessments";
                String primaryLabel = null;
                String primaryUrl = null;
                String primaryIcon = null;
                if (paidAccess && hasActiveAttempt) {
                    primaryLabel = "Continue";
                    primaryUrl = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&mode=attempt&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                    primaryIcon = "fa-play";
                } else if (paidAccess && used < Math.max(allowed, 1)) {
                    primaryLabel = "Start";
                    primaryUrl = request.getContextPath() + "/student/assessments?action=start&courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                    primaryIcon = "fa-play";
                }
                String secondaryLabel = "Details";
                String secondaryUrl = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                String secondaryIcon = "fa-info-circle";
                learningItems.add(new LearningItem(
                        orderIndex++,
                        "Assessment",
                        iconClass,
                        assessment.getTitle(),
                        assessment.getInstructions(),
                        assessment.getType(),
                        "learning-badge",
                        metaPrimary,
                        metaSecondary,
                        metaTertiary,
                        statusLabel,
                        statusClass,
                        !paidAccess,
                        lockReason,
                        primaryLabel,
                        primaryUrl,
                        primaryIcon,
                        secondaryLabel,
                        secondaryUrl,
                        secondaryIcon
                ));
            }

            String tab = request.getParameter("tab");
            if (tab == null || tab.trim().isEmpty()) tab = "learning";
            EnrollmentStateSyncService.SyncResult syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
            int progressPercent = syncResult.getProgressPercent();
            
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
            request.setAttribute("materialsViewedCount", syncResult.getViewedMaterials());
            request.setAttribute("learningItems", learningItems);
            request.getRequestDispatcher("/WEB-INF/views/student/enrollment-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            System.err.println("EnrollmentDetailsServlet: Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }

    private int resolveProgressPercent(Enrollment enrollment, List<Material> materials, List<Assessment> assessments, Integer userId) {
        if (enrollment == null || userId == null) return 0;
        if ("Completed".equalsIgnoreCase(enrollment.getCompletionStatus()) || "Completed".equalsIgnoreCase(enrollment.getStatus())) {
            return 100;
        }

        int totalMaterials = materials != null ? materials.size() : 0;
        int viewedMaterials = materialProgressDAO.countViewedByCourse(userId, enrollment.getCourseId());
        double materialRatio = totalMaterials == 0 ? 1.0 : Math.min(1.0, (double) viewedMaterials / totalMaterials);

        int totalAssessments = assessments != null ? assessments.size() : 0;
        int passedAssessments = 0;
        if (assessments != null) {
            for (Assessment a : assessments) {
                List<AssessmentSubmission> subs = submissionDAO.findByAssessmentAndUser(a.getAssessmentId(), userId);
                boolean passed = false;
                if (subs != null) {
                    for (AssessmentSubmission s : subs) {
                        if (s.getScore() == null) continue;
                        if ("TimedOut".equalsIgnoreCase(s.getStatus())) continue;
                        double threshold = resolvePassThreshold(a.getTotalMarks());
                        if (s.getScore() >= threshold) {
                            passed = true;
                            break;
                        }
                    }
                }
                if (passed) passedAssessments++;
            }
        }
        double assessmentRatio = totalAssessments == 0 ? 1.0 : Math.min(1.0, (double) passedAssessments / totalAssessments);

        int percent = (int) Math.round((materialRatio * 60.0) + (assessmentRatio * 40.0));
        return Math.max(0, Math.min(100, percent));
    }

    private double resolvePassThreshold(Integer totalMarks) {
        if (totalMarks == null || totalMarks <= 0) return 50.0;
        return totalMarks * 0.5;
    }

    private String resolveMaterialIcon(String materialType) {
        if (materialType == null) return "fa-file";
        switch (materialType.toLowerCase()) {
            case "pdf":
                return "fa-file-pdf";
            case "video":
                return "fa-play-circle";
            case "slides":
                return "fa-file-powerpoint";
            case "link":
                return "fa-link";
            default:
                return "fa-file";
        }
    }

    private String resolveAssessmentIcon(String type) {
        if (type == null) return "fa-clipboard-list";
        switch (type.toLowerCase()) {
            case "exam":
                return "fa-pen-nib";
            case "assignment":
                return "fa-file-alt";
            default:
                return "fa-clipboard-list";
        }
    }
}






