package com.psm.elearning.controller.student;

import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.dao.EnrollmentDAOImpl;
import com.psm.elearning.dao.MaterialDAO;
import com.psm.elearning.dao.MaterialDAOImpl;
import com.psm.elearning.dao.PaymentDAO;
import com.psm.elearning.dao.PaymentDAOImpl;
import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentDAOImpl;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentQuestionDAOImpl;
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
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.util.AssessmentPlacementUtil;
import com.psm.elearning.service.AppSettingsService;
import com.psm.elearning.service.EnrollmentStateSyncService;
import com.psm.elearning.util.SessionUtil;

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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet to display enrollment details.
 */
public class EnrollmentDetailsServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(EnrollmentDetailsServlet.class.getName());
    
    private EnrollmentDAO enrollmentDAO;
    private MaterialDAO materialDAO;
    private PaymentDAO paymentDAO;
    private AssessmentDAO assessmentDAO;
    private AssessmentSubmissionDAO submissionDAO;
        private AssessmentQuestionDAO assessmentQuestionDAO;
    private AssessmentRetakeRequestDAO retakeRequestDAO;
    private MaterialProgressDAO materialProgressDAO;
    private EnrollmentStateSyncService enrollmentStateSyncService;
    private com.psm.elearning.dao.CertificateDAO certificateDAO;

    public static class LearningItem {
        private Integer itemId;
        private String itemKind;
        private String navigationUrl;
        private boolean active;
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
        private final String groupLabel;
        private final String groupHint;
        private int groupCompletedItems;
        private int groupStartedItems;
        private int groupTotalItems;
        private int groupCompletionPercent;
        private String groupStatusLabel;
        private String groupStatusClass;
        private boolean completedForProgress;
        private boolean startedForProgress;
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
                             String groupLabel,
                             String groupHint,
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
            this.groupLabel = groupLabel;
            this.groupHint = groupHint;
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
        public String getGroupLabel() { return groupLabel; }
        public String getGroupHint() { return groupHint; }
        public int getGroupCompletedItems() { return groupCompletedItems; }
        public void setGroupCompletedItems(int groupCompletedItems) { this.groupCompletedItems = groupCompletedItems; }
        public int getGroupStartedItems() { return groupStartedItems; }
        public void setGroupStartedItems(int groupStartedItems) { this.groupStartedItems = groupStartedItems; }
        public int getGroupTotalItems() { return groupTotalItems; }
        public void setGroupTotalItems(int groupTotalItems) { this.groupTotalItems = groupTotalItems; }
        public int getGroupCompletionPercent() { return groupCompletionPercent; }
        public void setGroupCompletionPercent(int groupCompletionPercent) { this.groupCompletionPercent = groupCompletionPercent; }
        public String getGroupStatusLabel() { return groupStatusLabel; }
        public void setGroupStatusLabel(String groupStatusLabel) { this.groupStatusLabel = groupStatusLabel; }
        public String getGroupStatusClass() { return groupStatusClass; }
        public void setGroupStatusClass(String groupStatusClass) { this.groupStatusClass = groupStatusClass; }
        public boolean isCompletedForProgress() { return completedForProgress; }
        public void setCompletedForProgress(boolean completedForProgress) { this.completedForProgress = completedForProgress; }
        public boolean isStartedForProgress() { return startedForProgress; }
        public void setStartedForProgress(boolean startedForProgress) { this.startedForProgress = startedForProgress; }
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
        public Integer getItemId() { return itemId; }
        public void setItemId(Integer itemId) { this.itemId = itemId; }
        public String getItemKind() { return itemKind; }
        public void setItemKind(String itemKind) { this.itemKind = itemKind; }
        public String getNavigationUrl() { return navigationUrl; }
        public void setNavigationUrl(String navigationUrl) { this.navigationUrl = navigationUrl; }
        public boolean isActive() { return active; }
        public void setActive(boolean active) { this.active = active; }
    }

    public static class WorkspaceChip {
        private final String iconClass;
        private final String label;

        public WorkspaceChip(String iconClass, String label) {
            this.iconClass = iconClass;
            this.label = label;
        }

        public String getIconClass() { return iconClass; }
        public String getLabel() { return label; }
    }
    
    @Override
    public void init() {
        enrollmentDAO = new EnrollmentDAOImpl();
        materialDAO = new MaterialDAOImpl();
        paymentDAO = new PaymentDAOImpl();
        assessmentDAO = new AssessmentDAOImpl();
            assessmentQuestionDAO = new AssessmentQuestionDAOImpl();
        submissionDAO = new AssessmentSubmissionDAOImpl();
        retakeRequestDAO = new AssessmentRetakeRequestDAOImpl();
        materialProgressDAO = new MaterialProgressDAOImpl();
        enrollmentStateSyncService = new EnrollmentStateSyncService();
        certificateDAO = new com.psm.elearning.dao.CertificateDAOImpl();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (SessionUtil.resolveUserId(session) == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        if (!"Student".equals(SessionUtil.resolveRole(session))) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
        
        try {
            Integer userId = SessionUtil.resolveUserId(session);
            Integer enrollmentId = resolveEnrollmentId(request);
            if (enrollmentId == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
                return;
            }
            
            Enrollment enrollment = enrollmentDAO.getEnrollment(enrollmentId);
            
            if (enrollment == null) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=notfound");
                return;
            }

            // Sync enrollment state upon load
            try {
                enrollmentStateSyncService.syncEnrollmentState(enrollment);
            } catch (Exception syncEx) {
                LOGGER.log(Level.WARNING, "Failed to sync enrollment on page load", syncEx);
            }
            
            // Verify ownership
            if (!enrollment.getUserId().equals(userId)) {
                response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=unauthorized");
                return;
            }

            boolean safeMode = "1".equals(request.getParameter("safe")) || "true".equalsIgnoreCase(request.getParameter("safe"));
            if (safeMode) {
                request.setAttribute("enrollment", enrollment);
                request.setAttribute("materials", new ArrayList<Material>());
                request.setAttribute("assessments", new ArrayList<Assessment>());
                request.setAttribute("materialCount", 0);
                request.setAttribute("assessmentCount", 0);
                request.setAttribute("paidAccess", isPaymentComplete(enrollment.getPaymentStatus()));
                request.setAttribute("activeTab", "learning");
                request.setAttribute("progressPercent", enrollment.getProgress() != null ? enrollment.getProgress() : 0);
                request.setAttribute("usedAttemptsByAssessment", new LinkedHashMap<Integer, Integer>());
                request.setAttribute("allowedAttemptsByAssessment", new LinkedHashMap<Integer, Integer>());
                request.setAttribute("latestSubmissionByAssessment", new LinkedHashMap<Integer, AssessmentSubmission>());
                request.setAttribute("activeAttemptByAssessment", new LinkedHashMap<Integer, Boolean>());
                request.setAttribute("materialsViewedCount", 0);
                request.setAttribute("viewedMaterialIds", new HashSet<Integer>());
                request.setAttribute("learningItems", new ArrayList<LearningItem>());
                request.setAttribute("recommendedItem", null);
                request.setAttribute("courseAccessGranted", isPaymentComplete(enrollment.getPaymentStatus()) || enrollment.getCoursePrice() == null || enrollment.getCoursePrice() <= 0);
                request.setAttribute("focusMaterial", null);
                request.setAttribute("previousMaterial", null);
                request.setAttribute("nextMaterial", null);
                request.setAttribute("selectedMode", "empty");
                request.setAttribute("selectedMaterial", null);
                request.setAttribute("selectedMaterialId", null);
                request.setAttribute("selectedMaterialStatus", "");
                request.setAttribute("selectedAssessment", null);
                request.setAttribute("selectedAssessmentId", null);
                request.setAttribute("selectedAssessmentUsedAttempts", 0);
                request.setAttribute("selectedAssessmentAllowedAttempts", 0);
                request.setAttribute("selectedAssessmentLatest", null);
                request.setAttribute("selectedAssessmentHasActiveAttempt", false);
                request.setAttribute("selectedAssessmentStatusLabel", "Not Started");
                request.setAttribute("selectedAssessmentStatusClass", "status-Archived");
                request.setAttribute("selectedAssessmentPrimaryLabel", "");
                request.setAttribute("selectedAssessmentPrimaryUrl", "");
                request.setAttribute("workspaceEyebrow", "Learning Item");
                request.setAttribute("workspaceTitle", "Select an item from the course flow");
                request.setAttribute("workspaceDescription", "Choose a material or assessment from the sidebar to continue your course sequence.");
                request.setAttribute("workspaceStatusLabel", "Ready");
                request.setAttribute("workspaceStatusClass", "status-Pending");
                request.setAttribute("workspaceAccessLabel", "Workspace Ready");
                request.setAttribute("workspaceAccessIcon", "shield-check");
                request.setAttribute("workspaceChips", new ArrayList<WorkspaceChip>());
                request.setAttribute("workspaceActionNote", "Select an item from the course flow to continue.");
                request.setAttribute("workspacePrimaryActionIcon", "paper-plane");
                request.setAttribute("materialCompletionButtonLabel", "Mark Complete");
                request.setAttribute("certificateEligible", false);
                request.setAttribute("certificatePaidReady", isPaymentComplete(enrollment.getPaymentStatus()));
                request.setAttribute("certificateCompletedReady", false);
                request.setAttribute("certificateAssessmentsReady", false);
                request.setAttribute("certificateRemainingMaterials", 0);
                request.setAttribute("certificateRemainingAssessments", 0);
                request.setAttribute("certificateReadinessStepsComplete", 0);
                request.setAttribute("certificateReadinessPercent", 0);
                request.setAttribute("certificatePrimaryActionLabel", "Back to Courses");
                request.setAttribute("certificatePrimaryActionUrl", request.getContextPath() + "/student/my-enrollments");
                request.setAttribute("certificatePrimaryActionIcon", "fa-arrow-left");
                request.setAttribute("certificateReadinessHint", "We could not fully load this enrollment. Return to your course list and reopen it.");
                request.setAttribute("totalMaterialsCount", 0);
                request.setAttribute("passedAssessmentsCount", 0);
                request.setAttribute("totalAssessmentsCount", 0);
                request.getRequestDispatcher("/WEB-INF/views/student/enrollment-details.jsp").forward(request, response);
                return;
            }

            Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
            if (payment != null) {
                enrollment.setPaymentStatus(payment.getStatus());
                enrollment.setPaymentRef(payment.getPaystackReference());
            }

            boolean paidAccess = isPaymentComplete(enrollment.getPaymentStatus());
            boolean paymentRequired = enrollment.getCoursePrice() != null && enrollment.getCoursePrice() > 0;
            boolean courseAccessGranted = paidAccess || !paymentRequired;
            if (paymentRequired && !paidAccess) {
                response.sendRedirect(request.getContextPath() + "/student/payment?enrollmentId=" + enrollment.getEnrollmentId() + "&error=required");
                return;
            }

            List<Material> materials = new ArrayList<>();
            List<Assessment> assessments = new ArrayList<>();
            Set<Integer> viewedMaterialIds = new HashSet<>();
            if (enrollment.getCourseId() != null) {
                materials = materialDAO.findByCourse(enrollment.getCourseId());
                assessments = assessmentDAO.findByCourse(enrollment.getCourseId());
                viewedMaterialIds = materialProgressDAO.findViewedMaterialIdsByCourse(userId, enrollment.getCourseId());
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
                int defaultMaxAttempts = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_MAX_ATTEMPTS, 3, 1, 10);
                int base = assessment.getMaxAttempts() != null && assessment.getMaxAttempts() > 0 ? assessment.getMaxAttempts() : defaultMaxAttempts;
                int allowed = base + retakeRequestDAO.countApproved(assessment.getAssessmentId(), userId);
                usedAttemptsByAssessment.put(assessment.getAssessmentId(), used);
                allowedAttemptsByAssessment.put(assessment.getAssessmentId(), allowed);
                latestSubmissionByAssessment.put(assessment.getAssessmentId(), (submissions != null && !submissions.isEmpty()) ? submissions.get(0) : null);

                Object attemptStateObj = session.getAttribute("assessmentAttempt_" + assessment.getAssessmentId());
                boolean hasValidAttempt = false;
                if (attemptStateObj != null) {
                    try {
                        java.lang.reflect.Field deadlineField = attemptStateObj.getClass().getDeclaredField("deadlineMillis");
                        deadlineField.setAccessible(true);
                        long deadlineMillis = deadlineField.getLong(attemptStateObj);
                        hasValidAttempt = System.currentTimeMillis() < deadlineMillis;
                        if (!hasValidAttempt) {
                            session.removeAttribute("assessmentAttempt_" + assessment.getAssessmentId());
                        }
                    } catch (Exception e) {
                        hasValidAttempt = true;
                    }
                }
                activeAttemptByAssessment.put(assessment.getAssessmentId(), hasValidAttempt);
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
                AssessmentPlacementUtil.Placement placement = resolvePlacement(assessment);
                assessment.setPlacementType(placement.type);
                assessment.setPlacementMaterialId(placement.materialId);
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
                boolean viewed = viewedMaterialIds.contains(material.getMaterialId());
                String chapterLabel = material.getDisplayOrder() != null ? "Chapter " + material.getDisplayOrder() : "Learning Material";
                String chapterHint = "Read the material first, then continue with any linked assessments.";
                String iconClass = resolveMaterialIcon(material.getMaterialType());
                String badgeText = material.getMaterialType();
                String metaPrimary = material.getDisplayOrder() != null ? "Chapter " + material.getDisplayOrder() : "Material";
                String metaSecondary = material.getUploadDate() != null ? material.getUploadDate().toLocalDate().toString() : "";
                String metaTertiary = viewed ? "Viewed" : "Not yet viewed";
                String statusLabel = !courseAccessGranted ? "Locked" : (viewed ? "Completed" : "Ready");
                String statusClass = !courseAccessGranted ? "status-Pending" : (viewed ? "status-Approved" : "status-Archived");
                String lockReason = courseAccessGranted ? "" : "Payment required to access this material";
                String primaryLabel = viewed ? "Review" : "Open";
                String primaryIcon = "fa-eye";
                if ("Link".equalsIgnoreCase(material.getMaterialType())) {
                    primaryLabel = viewed ? "Reopen Link" : "Open Link";
                    primaryIcon = "fa-link";
                }
                String primaryAction = "Link".equalsIgnoreCase(material.getMaterialType()) ? "view" : "preview";
                String primaryUrl = courseAccessGranted
                    ? request.getContextPath() + "/student/materials?action=" + primaryAction + "&id=" + material.getMaterialId() + "&enrollmentId=" + enrollment.getEnrollmentId()
                    : null;
                String secondaryLabel = !"Link".equalsIgnoreCase(material.getMaterialType()) ? "Download" : null;
                String secondaryIcon = secondaryLabel != null ? "fa-download" : null;
                String secondaryUrl = (courseAccessGranted && secondaryLabel != null)
                    ? request.getContextPath() + "/student/materials?action=download&id=" + material.getMaterialId() + "&enrollmentId=" + enrollment.getEnrollmentId()
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
                        metaTertiary,
                        chapterLabel,
                        chapterHint,
                        statusLabel,
                        statusClass,
                        !courseAccessGranted,
                        lockReason,
                        primaryLabel,
                        primaryUrl,
                        primaryIcon,
                        secondaryLabel,
                        secondaryUrl,
                        secondaryIcon
                ));
                LearningItem currentItem = learningItems.get(learningItems.size() - 1);
                currentItem.setItemId(material.getMaterialId());
                currentItem.setItemKind("material");
                currentItem.setNavigationUrl(request.getContextPath()
                        + "/student/enrollment-details?id=" + enrollment.getEnrollmentId()
                        + "&tab=learning&materialId=" + material.getMaterialId());
                currentItem.setStartedForProgress(viewed);
                currentItem.setCompletedForProgress(viewed);

                List<Assessment> tiedAssessments = assessmentsAfterMaterial.getOrDefault(material.getMaterialId(), new ArrayList<>());
                for (Assessment assessment : tiedAssessments) {
                    int used = usedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                    int allowed = allowedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                    AssessmentSubmission latest = latestSubmissionByAssessment.get(assessment.getAssessmentId());
                    boolean hasActiveAttempt = activeAttemptByAssessment.getOrDefault(assessment.getAssessmentId(), false);
                    List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
                    EnrollmentStateSyncService.AssessmentProgressState progressState =
                            EnrollmentStateSyncService.resolveAssessmentProgress(assessment, submissions);
                    String assessmentStatusLabel;
                    String assessmentStatusClass;
                    if (!courseAccessGranted) {
                        assessmentStatusLabel = "Locked";
                        assessmentStatusClass = "status-Pending";
                    } else if (hasActiveAttempt) {
                        assessmentStatusLabel = "In Progress";
                        assessmentStatusClass = "status-Pending";
                    } else if (progressState.isPassed()) {
                        assessmentStatusLabel = "Completed";
                        assessmentStatusClass = "status-Approved";
                    } else if (progressState.isAttempted()) {
                        assessmentStatusLabel = latest != null && latest.getScore() == null ? "Awaiting Grade" : "Attempted";
                        assessmentStatusClass = "status-Pending";
                    } else {
                        assessmentStatusLabel = "Not Started";
                        assessmentStatusClass = "status-Archived";
                    }
                    String iconClassAssessment = resolveAssessmentIcon(assessment.getType());
                    String groupLabel = material.getDisplayOrder() != null ? "Chapter " + material.getDisplayOrder() : "Learning Material";
                    String groupHint = "This assessment follows the chapter immediately above.";
                    String metaPrimaryAssessment = (assessment.getDuration() != null ? assessment.getDuration() : 30) + " min";
                    String metaSecondaryAssessment = "Attempts: " + used + " / " + Math.max(allowed, 1);
                    String metaTertiaryAssessment = latest != null && latest.getScore() != null ? "Score: " + latest.getScore() : "";
                    String lockReasonAssessment = courseAccessGranted ? "" : "Payment required to take assessments";
                    String primaryLabelAssessment = null;
                    String primaryUrlAssessment = null;
                    String primaryIconAssessment = null;
                    if (courseAccessGranted && hasActiveAttempt) {
                        primaryLabelAssessment = "Continue";
                        primaryUrlAssessment = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&mode=attempt&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                        primaryIconAssessment = "fa-play";
                    } else if (courseAccessGranted && used < Math.max(allowed, 1)) {
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
                            groupLabel,
                            groupHint,
                            assessmentStatusLabel,
                            assessmentStatusClass,
                            !courseAccessGranted,
                            lockReasonAssessment,
                            primaryLabelAssessment,
                            primaryUrlAssessment,
                            primaryIconAssessment,
                            secondaryLabelAssessment,
                            secondaryUrlAssessment,
                            secondaryIconAssessment
                    ));
                    LearningItem addedAssessmentItem = learningItems.get(learningItems.size() - 1);
                    addedAssessmentItem.setItemId(assessment.getAssessmentId());
                    addedAssessmentItem.setItemKind("assessment");
                    addedAssessmentItem.setNavigationUrl(request.getContextPath()
                            + "/student/enrollment-details?id=" + enrollment.getEnrollmentId()
                            + "&tab=assessments&assessmentId=" + assessment.getAssessmentId());
                    addedAssessmentItem.setStartedForProgress(hasActiveAttempt || progressState.isAttempted());
                    addedAssessmentItem.setCompletedForProgress(progressState.isPassed());
                }
            }

            for (Assessment assessment : finalAssessments) {
                int used = usedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                int allowed = allowedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                AssessmentSubmission latest = latestSubmissionByAssessment.get(assessment.getAssessmentId());
                boolean hasActiveAttempt = activeAttemptByAssessment.getOrDefault(assessment.getAssessmentId(), false);
                List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), userId);
                EnrollmentStateSyncService.AssessmentProgressState progressState =
                        EnrollmentStateSyncService.resolveAssessmentProgress(assessment, submissions);
                String statusLabel;
                String statusClass;
                if (!courseAccessGranted) {
                    statusLabel = "Locked";
                    statusClass = "status-Pending";
                } else if (hasActiveAttempt) {
                    statusLabel = "In Progress";
                    statusClass = "status-Pending";
                } else if (progressState.isPassed()) {
                    statusLabel = "Completed";
                    statusClass = "status-Approved";
                } else if (progressState.isAttempted()) {
                    statusLabel = latest != null && latest.getScore() == null ? "Awaiting Grade" : "Attempted";
                    statusClass = "status-Pending";
                } else {
                    statusLabel = "Not Started";
                    statusClass = "status-Archived";
                }
                String iconClass = resolveAssessmentIcon(assessment.getType());
                String groupLabel = "Final Assessment Stage";
                String groupHint = "This assessment appears after the main learning materials.";
                String metaPrimary = (assessment.getDuration() != null ? assessment.getDuration() : 30) + " min";
                String metaSecondary = "Attempts: " + used + " / " + Math.max(allowed, 1);
                String metaTertiary = latest != null && latest.getScore() != null ? "Score: " + latest.getScore() : "";
                String lockReason = courseAccessGranted ? "" : "Payment required to take assessments";
                String primaryLabel = null;
                String primaryUrl = null;
                String primaryIcon = null;
                if (courseAccessGranted && hasActiveAttempt) {
                    primaryLabel = "Continue";
                    primaryUrl = request.getContextPath() + "/student/assessments?courseId=" + enrollment.getCourseId() + "&assessmentId=" + assessment.getAssessmentId() + "&mode=attempt&fromHub=1&enrollmentId=" + enrollment.getEnrollmentId();
                    primaryIcon = "fa-play";
                } else if (courseAccessGranted && used < Math.max(allowed, 1)) {
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
                        groupLabel,
                        groupHint,
                        statusLabel,
                        statusClass,
                        !courseAccessGranted,
                        lockReason,
                        primaryLabel,
                        primaryUrl,
                        primaryIcon,
                        secondaryLabel,
                        secondaryUrl,
                        secondaryIcon
                ));
                LearningItem addedFinalAssessmentItem = learningItems.get(learningItems.size() - 1);
                addedFinalAssessmentItem.setItemId(assessment.getAssessmentId());
                addedFinalAssessmentItem.setItemKind("assessment");
                addedFinalAssessmentItem.setNavigationUrl(request.getContextPath()
                        + "/student/enrollment-details?id=" + enrollment.getEnrollmentId()
                        + "&tab=assessments&assessmentId=" + assessment.getAssessmentId());
                addedFinalAssessmentItem.setStartedForProgress(hasActiveAttempt || progressState.isAttempted());
                addedFinalAssessmentItem.setCompletedForProgress(progressState.isPassed());
            }

            Map<String, Integer> groupTotals = new LinkedHashMap<>();
            Map<String, Integer> groupCompleted = new LinkedHashMap<>();
            Map<String, Integer> groupStarted = new LinkedHashMap<>();
            for (LearningItem item : learningItems) {
                String key = item.getGroupLabel();
                groupTotals.put(key, groupTotals.getOrDefault(key, 0) + 1);
                if (item.isCompletedForProgress()) {
                    groupCompleted.put(key, groupCompleted.getOrDefault(key, 0) + 1);
                }
                if (item.isStartedForProgress()) {
                    groupStarted.put(key, groupStarted.getOrDefault(key, 0) + 1);
                }
            }
            for (LearningItem item : learningItems) {
                String key = item.getGroupLabel();
                int total = groupTotals.getOrDefault(key, 0);
                int completedCount = groupCompleted.getOrDefault(key, 0);
                int startedCount = groupStarted.getOrDefault(key, 0);
                int percent = total == 0 ? 0 : (int) Math.round((completedCount * 100.0) / total);
                String groupStatusLabel;
                String groupStatusClass;
                if (completedCount == 0 && startedCount == 0) {
                    groupStatusLabel = "Not Started";
                    groupStatusClass = "status-Archived";
                } else if (completedCount >= total) {
                    groupStatusLabel = "Complete";
                    groupStatusClass = "status-Approved";
                } else {
                    groupStatusLabel = "In Progress";
                    groupStatusClass = "status-Pending";
                }
                item.setGroupTotalItems(total);
                item.setGroupCompletedItems(completedCount);
                item.setGroupStartedItems(startedCount);
                item.setGroupCompletionPercent(percent);
                item.setGroupStatusLabel(groupStatusLabel);
                item.setGroupStatusClass(groupStatusClass);
            }

            LearningItem recommendedItem = null;
            for (LearningItem item : learningItems) {
                if (!item.isLocked() && !"Completed".equalsIgnoreCase(item.getStatusLabel())) {
                    recommendedItem = item;
                    break;
                }
            }
            if (recommendedItem == null && !learningItems.isEmpty()) {
                recommendedItem = learningItems.get(0);
            }

            Material focusMaterial = null;
            Material previousMaterial = null;
            Material nextMaterial = null;
                LOGGER.info("EnrollmentDetailsServlet: enrollmentId=" + enrollmentId
                    + ", courseId=" + enrollment.getCourseId()
                    + ", materialCount=" + orderedMaterials.size()
                    + ", assessmentCount=" + assessments.size());
            if (!orderedMaterials.isEmpty()) {
                int focusIndex = -1;
                for (int i = 0; i < orderedMaterials.size(); i++) {
                    Material candidate = orderedMaterials.get(i);
                    if (!viewedMaterialIds.contains(candidate.getMaterialId())) {
                        focusIndex = i;
                        break;
                    }
                }
                if (focusIndex < 0) {
                    focusIndex = orderedMaterials.size() - 1;
                }
                focusMaterial = orderedMaterials.get(focusIndex);
                if (focusIndex > 0) {
                    previousMaterial = orderedMaterials.get(focusIndex - 1);
                }
                if (focusIndex + 1 < orderedMaterials.size()) {
                    nextMaterial = orderedMaterials.get(focusIndex + 1);
                }
            }

            String tab = request.getParameter("tab");
            if (tab == null || tab.trim().isEmpty()) tab = "learning";
            Map<Integer, String> materialStatusById = materialProgressDAO.findMaterialStatusByCourse(userId, enrollment.getCourseId());

            Integer currentAssessmentId = null;
            for (Assessment assessment : assessments) {
                int used = usedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                int allowed = allowedAttemptsByAssessment.getOrDefault(assessment.getAssessmentId(), 0);
                if (activeAttemptByAssessment.getOrDefault(assessment.getAssessmentId(), false) || used < allowed) {
                    currentAssessmentId = assessment.getAssessmentId();
                    break;
                }
            }
            if (currentAssessmentId == null && !assessments.isEmpty()) {
                currentAssessmentId = assessments.get(0).getAssessmentId();
            }

            Integer requestedAssessmentId = parseIntegerParameter(request.getParameter("assessmentId"));
            Integer requestedSubmissionId = parseIntegerParameter(request.getParameter("submissionId"));
            Integer requestedMaterialId = parseIntegerParameter(request.getParameter("materialId"));
            Assessment selectedAssessment = null;
            Material selectedMaterial = null;
            String selectedMode = "empty";

            LOGGER.info("EnrollmentDetailsServlet: tab=" + tab
                    + ", requestedMaterialId=" + requestedMaterialId
                    + ", requestedAssessmentId=" + requestedAssessmentId);

            if ("assessments".equalsIgnoreCase(tab)) {
                Integer effectiveAssessmentId = requestedAssessmentId != null ? requestedAssessmentId : currentAssessmentId;
                selectedAssessment = findAssessmentById(assessments, effectiveAssessmentId);
            } else {
                Integer effectiveMaterialId = requestedMaterialId != null
                        ? requestedMaterialId
                        : (focusMaterial != null ? focusMaterial.getMaterialId() : null);
                selectedMaterial = findMaterialById(orderedMaterials, effectiveMaterialId);
            }

            if (selectedAssessment == null && requestedAssessmentId != null) {
                selectedAssessment = findAssessmentById(assessments, requestedAssessmentId);
            }
            if (selectedMaterial == null && requestedMaterialId != null) {
                selectedMaterial = findMaterialById(orderedMaterials, requestedMaterialId);
            }

            if (selectedMaterial == null && selectedAssessment == null && focusMaterial != null) {
                selectedMaterial = focusMaterial;
            }
            if (selectedMaterial == null && selectedAssessment == null && currentAssessmentId != null) {
                selectedAssessment = findAssessmentById(assessments, currentAssessmentId);
            }
            LOGGER.info("EnrollmentDetailsServlet: selectedMaterialId="
                    + (selectedMaterial != null ? selectedMaterial.getMaterialId() : null)
                    + ", selectedAssessmentId="
                    + (selectedAssessment != null ? selectedAssessment.getAssessmentId() : null));

            selectedMode = selectedAssessment != null ? "assessment" : (selectedMaterial != null ? "material" : "empty");
            if ("assessment".equals(selectedMode)) {
                tab = "assessments";
            } else if ("material".equals(selectedMode)) {
                tab = "learning";
            }
            Integer selectedMaterialId = selectedMaterial != null ? selectedMaterial.getMaterialId() : null;
            Integer selectedAssessmentId = selectedAssessment != null ? selectedAssessment.getAssessmentId() : null;
            String selectedMaterialStatus = selectedMaterialId != null ? materialStatusById.getOrDefault(selectedMaterialId, "") : "";
            if (selectedMaterialId != null && courseAccessGranted && !"completed".equalsIgnoreCase(selectedMaterialStatus)) {
                try {
                    materialProgressDAO.markInProgress(userId, selectedMaterialId, enrollment.getCourseId());
                    selectedMaterialStatus = materialStatusById.getOrDefault(selectedMaterialId, "in_progress");
                } catch (Exception progressException) {
                    LOGGER.log(Level.WARNING, "EnrollmentDetailsServlet: unable to mark material in progress", progressException);
                }
            }
            int selectedAssessmentUsedAttempts = selectedAssessment != null
                    ? usedAttemptsByAssessment.getOrDefault(selectedAssessment.getAssessmentId(), 0)
                    : 0;
            int selectedAssessmentAllowedAttempts = selectedAssessment != null
                    ? allowedAttemptsByAssessment.getOrDefault(selectedAssessment.getAssessmentId(), 0)
                    : 0;
            AssessmentSubmission selectedAssessmentLatest = selectedAssessment != null
                    ? latestSubmissionByAssessment.get(selectedAssessment.getAssessmentId())
                    : null;
            boolean selectedAssessmentHasActiveAttempt = selectedAssessment != null
                    && activeAttemptByAssessment.getOrDefault(selectedAssessment.getAssessmentId(), false);
            String selectedAssessmentStatusLabel = "Not Started";
            String selectedAssessmentStatusClass = "status-Archived";
            String selectedAssessmentPrimaryLabel = "";
            String selectedAssessmentPrimaryUrl = "";
            String workspaceEyebrow = "Learning Item";
            String workspaceTitle = "Select an item from the course flow";
            String workspaceDescription = "Choose a material or assessment from the sidebar to continue your course sequence.";
            String workspaceStatusLabel = "Ready";
            String workspaceStatusClass = "status-Pending";
            String workspaceAccessLabel = courseAccessGranted ? "Workspace Ready" : "Payment Required";
            String workspaceAccessIcon = courseAccessGranted ? "shield-check" : "lock";
            String workspaceActionNote = "Select an item from the course flow to continue.";
            String workspacePrimaryActionIcon = "paper-plane";
            String materialCompletionButtonLabel = "Mark Complete";
            List<WorkspaceChip> workspaceChips = new ArrayList<>();

            if (requestedAssessmentId != null && requestedSubmissionId != null) {
                Assessment resultAssessment = assessmentDAO.findById(requestedAssessmentId);
                AssessmentSubmission resultSubmission = submissionDAO.findById(requestedSubmissionId);
                if (resultAssessment != null
                        && resultSubmission != null
                        && resultSubmission.getUserId() != null
                        && resultSubmission.getUserId().equals(userId)
                        && resultSubmission.getAssessmentId() != null
                        && resultSubmission.getAssessmentId().equals(requestedAssessmentId)) {
                    List<AssessmentQuestion> resultQuestions = assessmentQuestionDAO.findByAssessment(requestedAssessmentId);
                    Map<Integer, String> studentAnswers = parseObjectiveAnswers(resultSubmission.getAnswersFilePath());
                    Map<Integer, String> correctAnswers = new LinkedHashMap<>();
                    if (resultQuestions != null) {
                        for (AssessmentQuestion question : resultQuestions) {
                            correctAnswers.put(question.getQuestionId(), question.getCorrectOption());
                        }
                    }

                    request.setAttribute("assessmentResultAssessment", resultAssessment);
                    request.setAttribute("assessmentResultSubmission", resultSubmission);
                    request.setAttribute("assessmentResultQuestions", resultQuestions != null ? resultQuestions : new ArrayList<AssessmentQuestion>());
                    request.setAttribute("assessmentResultStudentAnswers", studentAnswers);
                    request.setAttribute("assessmentResultCorrectAnswers", correctAnswers);
                    request.setAttribute("assessmentResultObjective", !"Assignment".equalsIgnoreCase(resultAssessment.getType()));
                    request.setAttribute("assessmentResultPercentage", computePercentage(resultSubmission.getScore(), resultAssessment.getTotalMarks()));
                    request.setAttribute("assessmentResultStatusLabel", humanizeSubmissionStatus(resultSubmission));
                    request.setAttribute("assessmentResultStatusClass", statusClassForSubmission(resultSubmission));

                    selectedAssessment = resultAssessment;
                    selectedAssessmentLatest = resultSubmission;
                    selectedAssessmentStatusLabel = humanizeSubmissionStatus(resultSubmission);
                    selectedAssessmentStatusClass = statusClassForSubmission(resultSubmission);
                    selectedAssessmentPrimaryLabel = "View Details";
                    selectedAssessmentPrimaryUrl = request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=assessments&view=result&assessmentId=" + resultAssessment.getAssessmentId() + "&submissionId=" + resultSubmission.getSubmissionId();
                    selectedMode = "result";
                    tab = "assessments";
                    workspaceEyebrow = "Results & Feedback";
                    workspaceTitle = resultAssessment.getTitle();
                    workspaceDescription = "Review your score, submission details, and feedback inside the learning hub.";
                    workspaceStatusLabel = humanizeSubmissionStatus(resultSubmission);
                    workspaceStatusClass = statusClassForSubmission(resultSubmission);
                    workspaceActionNote = "Results are shown inside the learning hub.";
                    workspacePrimaryActionIcon = "chart-column";
                }
            }

            if (selectedAssessment != null && !"result".equals(selectedMode)) {
                if (!courseAccessGranted) {
                    selectedAssessmentStatusLabel = "Locked";
                    selectedAssessmentStatusClass = "status-Pending";
                } else if (selectedAssessmentHasActiveAttempt) {
                    selectedAssessmentStatusLabel = "In Progress";
                    selectedAssessmentStatusClass = "status-Pending";
                } else if (selectedAssessmentLatest != null && selectedAssessmentLatest.getScore() != null) {
                    selectedAssessmentStatusLabel = "Completed";
                    selectedAssessmentStatusClass = "status-Approved";
                } else if (selectedAssessmentLatest != null) {
                    selectedAssessmentStatusLabel = "Awaiting Grade";
                    selectedAssessmentStatusClass = "status-Pending";
                }

                if (courseAccessGranted && selectedAssessmentHasActiveAttempt) {
                    selectedAssessmentPrimaryLabel = Assessment.TYPE_ASSIGNMENT.equals(selectedAssessment.getType())
                            ? "Continue Submission"
                            : "Continue Assessment";
                    selectedAssessmentPrimaryUrl = buildCourseAssessmentUrl(request, enrollment.getEnrollmentId(), enrollment.getCourseId(), selectedAssessment.getAssessmentId(), Assessment.TYPE_ASSIGNMENT.equals(selectedAssessment.getType()));
                } else if (courseAccessGranted && selectedAssessmentUsedAttempts < selectedAssessmentAllowedAttempts) {
                    selectedAssessmentPrimaryLabel = Assessment.TYPE_ASSIGNMENT.equals(selectedAssessment.getType())
                            ? "Open Assignment"
                            : "Start Assessment";
                    selectedAssessmentPrimaryUrl = buildCourseAssessmentUrl(request, enrollment.getEnrollmentId(), enrollment.getCourseId(), selectedAssessment.getAssessmentId(), Assessment.TYPE_ASSIGNMENT.equals(selectedAssessment.getType()));
                } else if (selectedAssessmentLatest != null && selectedAssessmentLatest.getSubmissionId() != null) {
                    selectedAssessmentPrimaryLabel = "View Result";
                    selectedAssessmentPrimaryUrl = request.getContextPath()
                            + "/student/enrollment-details?id=" + enrollment.getEnrollmentId()
                            + "&tab=assessments&view=result"
                            + "&assessmentId=" + selectedAssessment.getAssessmentId()
                            + "&submissionId=" + selectedAssessmentLatest.getSubmissionId();
                }

                workspaceEyebrow = selectedAssessment.getType();
                workspaceTitle = selectedAssessment.getTitle();
                workspaceDescription = selectedAssessment.getInstructions() != null && !selectedAssessment.getInstructions().trim().isEmpty()
                        ? selectedAssessment.getInstructions()
                        : "Review the assessment details below, then use the action bar to start or continue.";
                workspaceStatusLabel = selectedAssessmentStatusLabel;
                workspaceStatusClass = selectedAssessmentStatusClass;
                if (!courseAccessGranted) {
                    workspaceActionNote = "Assessment access will unlock after payment is completed.";
                } else if (selectedAssessmentHasActiveAttempt) {
                    workspaceActionNote = "Continue the active attempt when you are ready.";
                } else if (Assessment.TYPE_ASSIGNMENT.equals(selectedAssessment.getType())) {
                    workspaceActionNote = "Use the submit action to open the upload workspace and send your response.";
                } else {
                    workspaceActionNote = "Start the assessment from here when you are ready to proceed.";
                }
                workspacePrimaryActionIcon = selectedAssessmentHasActiveAttempt
                        ? "play"
                        : ("View Result".equals(selectedAssessmentPrimaryLabel) ? "eye" : "paper-plane");
                workspaceChips.add(new WorkspaceChip("fa-layer-group", selectedAssessment.getType()));
                workspaceChips.add(new WorkspaceChip("fa-clock", (selectedAssessment.getDuration() != null ? selectedAssessment.getDuration() : 30) + " min"));
                workspaceChips.add(new WorkspaceChip("fa-repeat", selectedAssessmentUsedAttempts + " / " + selectedAssessmentAllowedAttempts + " attempts"));
                workspaceChips.add(new WorkspaceChip("fa-upload", resolveSubmissionModeLabel(selectedAssessment.getSubmissionMode())));
            } else if (selectedMaterial != null) {
                workspaceEyebrow = selectedMaterial.getMaterialType();
                workspaceTitle = selectedMaterial.getTitle();
                workspaceDescription = selectedMaterial.getDescription() != null && !selectedMaterial.getDescription().trim().isEmpty()
                        ? selectedMaterial.getDescription()
                        : "Choose a material or assessment from the sidebar to continue your course sequence.";
                workspaceStatusLabel = "completed".equalsIgnoreCase(selectedMaterialStatus) ? "Completed" : "In Progress";
                workspaceStatusClass = "completed".equalsIgnoreCase(selectedMaterialStatus) ? "status-Approved" : "status-Pending";
                if ("completed".equalsIgnoreCase(selectedMaterialStatus)) {
                    workspaceActionNote = "This material is already counted in your progress.";
                    materialCompletionButtonLabel = "Completed";
                } else if (Material.TYPE_VIDEO.equalsIgnoreCase(selectedMaterial.getMaterialType())
                        || "Audio".equalsIgnoreCase(selectedMaterial.getMaterialType())) {
                    workspaceActionNote = "Playback unlocks completion once you reach the required threshold.";
                } else if (Material.TYPE_LINK.equalsIgnoreCase(selectedMaterial.getMaterialType())) {
                    workspaceActionNote = "Open the external resource in the viewer, then mark it complete here.";
                } else {
                    workspaceActionNote = "Review the current material, then mark it complete from the action bar.";
                }
                workspacePrimaryActionIcon = "check-circle";
                workspaceChips.add(new WorkspaceChip("fa-tag", selectedMaterial.getMaterialType()));
                if (selectedMaterial.getDisplayOrder() != null) {
                    workspaceChips.add(new WorkspaceChip("fa-list-ol", "Section " + selectedMaterial.getDisplayOrder()));
                }
                workspaceChips.add(new WorkspaceChip("fa-eye", viewedMaterialIds.size() + " / " + materials.size() + " completed"));
                workspaceChips.add(new WorkspaceChip("fa-circle-check", "completed".equalsIgnoreCase(selectedMaterialStatus) ? "Completed" : "Ready to review"));
            }

            for (LearningItem item : learningItems) {
                boolean active = "material".equals(item.getItemKind())
                        ? selectedMaterialId != null && selectedMaterialId.equals(item.getItemId())
                        : (selectedAssessmentId != null && selectedAssessmentId.equals(item.getItemId()));
                item.setActive(active);
            }

            EnrollmentStateSyncService.SyncResult syncResult;
            try {
                syncResult = enrollmentStateSyncService.syncEnrollmentState(enrollment);
            } catch (Exception syncException) {
                LOGGER.log(Level.WARNING, "EnrollmentDetailsServlet: sync failed", syncException);
                syncResult = null;
            }

            int progressPercent = syncResult != null
                    ? syncResult.getProgressPercent()
                    : resolveProgressPercent(enrollment, materials, assessments, userId);
            int materialsViewedCount = syncResult != null ? syncResult.getViewedMaterials() : viewedMaterialIds.size();
            int totalMaterialsCount = syncResult != null ? syncResult.getTotalMaterials() : materials.size();
            int passedAssessmentsCount = syncResult != null ? syncResult.getPassedAssessments() : 0;
            int totalAssessmentsCount = syncResult != null ? syncResult.getTotalAssessments() : assessments.size();
            boolean freeCourse = enrollment.getCoursePrice() <= 0;
            boolean eligibleForCertificate = syncResult != null
                    ? syncResult.isEligibleForCertificate()
                    : (paidAccess && totalMaterialsCount > 0 && materialsViewedCount >= totalMaterialsCount && passedAssessmentsCount >= totalAssessmentsCount);
            if (freeCourse) {
                eligibleForCertificate = false;
            }
            
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
            request.setAttribute("materialsViewedCount", materialsViewedCount);
            request.setAttribute("viewedMaterialIds", viewedMaterialIds);
            request.setAttribute("materialStatusById", materialStatusById);
            request.setAttribute("learningItems", learningItems);
            request.setAttribute("recommendedItem", recommendedItem);
            request.setAttribute("courseAccessGranted", courseAccessGranted);
            request.setAttribute("focusMaterial", focusMaterial);
            request.setAttribute("previousMaterial", previousMaterial);
            request.setAttribute("nextMaterial", nextMaterial);
            request.setAttribute("selectedMode", selectedMode);
            request.setAttribute("selectedMaterial", selectedMaterial);
            request.setAttribute("selectedMaterialId", selectedMaterialId);
            request.setAttribute("selectedMaterialStatus", selectedMaterialStatus);
            request.setAttribute("selectedAssessment", selectedAssessment);
            request.setAttribute("selectedAssessmentId", selectedAssessmentId);
            request.setAttribute("selectedAssessmentUsedAttempts", selectedAssessmentUsedAttempts);
            request.setAttribute("selectedAssessmentAllowedAttempts", selectedAssessmentAllowedAttempts);
            request.setAttribute("selectedAssessmentLatest", selectedAssessmentLatest);
            request.setAttribute("selectedAssessmentHasActiveAttempt", selectedAssessmentHasActiveAttempt);
            request.setAttribute("selectedAssessmentStatusLabel", selectedAssessmentStatusLabel);
            request.setAttribute("selectedAssessmentStatusClass", selectedAssessmentStatusClass);
            request.setAttribute("selectedAssessmentPrimaryLabel", selectedAssessmentPrimaryLabel);
            request.setAttribute("selectedAssessmentPrimaryUrl", selectedAssessmentPrimaryUrl);
            request.setAttribute("workspaceEyebrow", workspaceEyebrow);
            request.setAttribute("workspaceTitle", workspaceTitle);
            request.setAttribute("workspaceDescription", workspaceDescription);
            request.setAttribute("workspaceStatusLabel", workspaceStatusLabel);
            request.setAttribute("workspaceStatusClass", workspaceStatusClass);
            request.setAttribute("workspaceAccessLabel", workspaceAccessLabel);
            request.setAttribute("workspaceAccessIcon", workspaceAccessIcon);
            request.setAttribute("workspaceChips", workspaceChips);
            request.setAttribute("workspaceActionNote", workspaceActionNote);
            request.setAttribute("workspacePrimaryActionIcon", workspacePrimaryActionIcon);
            request.setAttribute("materialCompletionButtonLabel", materialCompletionButtonLabel);
            int remainingMaterials = Math.max(0, totalMaterialsCount - materialsViewedCount);
            int remainingAssessments = Math.max(0, totalAssessmentsCount - passedAssessmentsCount);
            int readinessStepsComplete = 0;
            if (syncResult != null ? syncResult.isPaid() : paidAccess) readinessStepsComplete++;
            if (syncResult != null ? syncResult.isCompleted() : (remainingMaterials == 0 && remainingAssessments == 0)) readinessStepsComplete++;
            if (syncResult != null ? syncResult.isPassedAllAssessments() : remainingAssessments == 0) readinessStepsComplete++;
            int readinessPercent = (int) Math.round((readinessStepsComplete / 3.0) * 100.0);

            boolean paid = syncResult != null ? syncResult.isPaid() : paidAccess;
            boolean completed = syncResult != null ? syncResult.isCompleted() : (remainingMaterials == 0 && remainingAssessments == 0);
            boolean passedAllAssessments = syncResult != null ? syncResult.isPassedAllAssessments() : remainingAssessments == 0;

            String readinessPrimaryLabel;
            String readinessPrimaryUrl;
            String readinessPrimaryIcon;
            String readinessHint;
            if (freeCourse) {
                readinessPrimaryLabel = "Continue Learning";
                readinessPrimaryUrl = request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=learning";
                readinessPrimaryIcon = "fa-layer-group";
                readinessHint = "Free courses do not include certificates. Continue learning materials and assessments directly.";
            } else if (!paid) {
                readinessPrimaryLabel = "Complete Payment";
                readinessPrimaryUrl = request.getContextPath() + "/student/payment?enrollmentId=" + enrollment.getEnrollmentId();
                readinessPrimaryIcon = "fa-credit-card";
                readinessHint = "Payment must be successful before the system can unlock certificate generation.";
            } else if (remainingMaterials > 0) {
                readinessPrimaryLabel = "Continue Learning";
                readinessPrimaryUrl = request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=learning";
                readinessPrimaryIcon = "fa-layer-group";
                readinessHint = remainingMaterials == 1
                        ? "You still need to complete 1 more learning material before the course can be marked complete."
                        : "You still need to complete " + remainingMaterials + " more learning materials before the course can be marked complete.";
            } else if (remainingAssessments > 0) {
                readinessPrimaryLabel = "Finish Assessments";
                readinessPrimaryUrl = request.getContextPath() + "/student/enrollment-details?id=" + enrollment.getEnrollmentId() + "&tab=assessments";
                readinessPrimaryIcon = "fa-clipboard-check";
                readinessHint = remainingAssessments == 1
                        ? "You still need to pass 1 required assessment before certificate generation becomes available."
                        : "You still need to pass " + remainingAssessments + " required assessments before certificate generation becomes available.";
            } else {
                readinessPrimaryLabel = "Open Certificates";
                readinessPrimaryUrl = request.getContextPath() + "/student/certificates";
                readinessPrimaryIcon = "fa-certificate";
                readinessHint = eligibleForCertificate
                        ? "Everything is in place. You can open your certificate area and generate the certificate for this course."
                        : "Your records are almost ready. Open the certificate area to review your current status.";
            }

            com.psm.elearning.model.Certificate userCertificate = null;
            try {
                userCertificate = certificateDAO.findByEnrollment(enrollment.getEnrollmentId());
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to query certificate in enrollment details", e);
            }
            request.setAttribute("userCertificate", userCertificate);

            request.setAttribute("certificateEligible", eligibleForCertificate);
            request.setAttribute("certificatePaidReady", paid);
            request.setAttribute("certificateCompletedReady", completed);
            request.setAttribute("certificateAssessmentsReady", passedAllAssessments);
            request.setAttribute("certificateRemainingMaterials", remainingMaterials);
            request.setAttribute("certificateRemainingAssessments", remainingAssessments);
            request.setAttribute("certificateReadinessStepsComplete", readinessStepsComplete);
            request.setAttribute("certificateReadinessPercent", readinessPercent);
            request.setAttribute("certificatePrimaryActionLabel", readinessPrimaryLabel);
            request.setAttribute("certificatePrimaryActionUrl", readinessPrimaryUrl);
            request.setAttribute("certificatePrimaryActionIcon", readinessPrimaryIcon);
            request.setAttribute("certificateReadinessHint", readinessHint);
            request.setAttribute("totalMaterialsCount", totalMaterialsCount);
            request.setAttribute("passedAssessmentsCount", passedAssessmentsCount);
            request.setAttribute("totalAssessmentsCount", totalAssessmentsCount);
            request.getRequestDispatcher("/WEB-INF/views/student/enrollment-details.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=invalid");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "EnrollmentDetailsServlet: Error loading enrollment details", e);
            try {
                Integer userId = SessionUtil.resolveUserId(session);
                Integer fallbackEnrollmentId = null;
                String fallbackId = request.getParameter("id");
                if (fallbackId == null || fallbackId.trim().isEmpty()) {
                    fallbackId = request.getParameter("enrollmentId");
                }
                if (fallbackId != null && !fallbackId.trim().isEmpty()) {
                    fallbackEnrollmentId = Integer.valueOf(fallbackId.trim());
                }
                Enrollment fallbackEnrollment = fallbackEnrollmentId != null ? enrollmentDAO.getEnrollment(fallbackEnrollmentId) : null;
                if (fallbackEnrollment != null && fallbackEnrollment.getUserId() != null && fallbackEnrollment.getUserId().equals(userId)) {
                    request.setAttribute("enrollment", fallbackEnrollment);
                    request.setAttribute("materials", new ArrayList<Material>());
                    request.setAttribute("assessments", new ArrayList<Assessment>());
                    request.setAttribute("materialCount", 0);
                    request.setAttribute("assessmentCount", 0);
                    request.setAttribute("paidAccess", false);
                    request.setAttribute("activeTab", "learning");
                    request.setAttribute("progressPercent", 0);
                    request.setAttribute("usedAttemptsByAssessment", new LinkedHashMap<Integer, Integer>());
                    request.setAttribute("allowedAttemptsByAssessment", new LinkedHashMap<Integer, Integer>());
                    request.setAttribute("latestSubmissionByAssessment", new LinkedHashMap<Integer, AssessmentSubmission>());
                    request.setAttribute("activeAttemptByAssessment", new LinkedHashMap<Integer, Boolean>());
                    request.setAttribute("materialsViewedCount", 0);
                    request.setAttribute("viewedMaterialIds", new HashSet<Integer>());
                    request.setAttribute("learningItems", new ArrayList<LearningItem>());
                    request.setAttribute("recommendedItem", null);
                    request.setAttribute("courseAccessGranted", false);
                    request.setAttribute("focusMaterial", null);
                    request.setAttribute("previousMaterial", null);
                    request.setAttribute("nextMaterial", null);
                    request.setAttribute("selectedMode", "empty");
                    request.setAttribute("selectedMaterial", null);
                    request.setAttribute("selectedMaterialId", null);
                    request.setAttribute("selectedMaterialStatus", "");
                    request.setAttribute("selectedAssessment", null);
                    request.setAttribute("selectedAssessmentId", null);
                    request.setAttribute("selectedAssessmentUsedAttempts", 0);
                    request.setAttribute("selectedAssessmentAllowedAttempts", 0);
                    request.setAttribute("selectedAssessmentLatest", null);
                    request.setAttribute("selectedAssessmentHasActiveAttempt", false);
                    request.setAttribute("selectedAssessmentStatusLabel", "Not Started");
                    request.setAttribute("selectedAssessmentStatusClass", "status-Archived");
                    request.setAttribute("selectedAssessmentPrimaryLabel", "");
                    request.setAttribute("selectedAssessmentPrimaryUrl", "");
                    request.setAttribute("workspaceEyebrow", "Learning Item");
                    request.setAttribute("workspaceTitle", "Select an item from the course flow");
                    request.setAttribute("workspaceDescription", "Choose a material or assessment from the sidebar to continue your course sequence.");
                    request.setAttribute("workspaceStatusLabel", "Ready");
                    request.setAttribute("workspaceStatusClass", "status-Pending");
                    request.setAttribute("workspaceAccessLabel", "Payment Required");
                    request.setAttribute("workspaceAccessIcon", "lock");
                    request.setAttribute("workspaceChips", new ArrayList<WorkspaceChip>());
                    request.setAttribute("workspaceActionNote", "Select an item from the course flow to continue.");
                    request.setAttribute("workspacePrimaryActionIcon", "paper-plane");
                    request.setAttribute("materialCompletionButtonLabel", "Mark Complete");
                    request.setAttribute("certificateEligible", false);
                    request.setAttribute("certificatePaidReady", false);
                    request.setAttribute("certificateCompletedReady", false);
                    request.setAttribute("certificateAssessmentsReady", false);
                    request.setAttribute("certificateRemainingMaterials", 0);
                    request.setAttribute("certificateRemainingAssessments", 0);
                    request.setAttribute("certificateReadinessStepsComplete", 0);
                    request.setAttribute("certificateReadinessPercent", 0);
                    request.setAttribute("certificatePrimaryActionLabel", "Back to Courses");
                    request.setAttribute("certificatePrimaryActionUrl", request.getContextPath() + "/student/my-enrollments");
                    request.setAttribute("certificatePrimaryActionIcon", "fa-arrow-left");
                    request.setAttribute("certificateReadinessHint", "We could not fully load this enrollment. Return to your course list and reopen it.");
                    request.setAttribute("totalMaterialsCount", 0);
                    request.setAttribute("passedAssessmentsCount", 0);
                    request.setAttribute("totalAssessmentsCount", 0);
                    request.getRequestDispatcher("/WEB-INF/views/student/enrollment-details.jsp").forward(request, response);
                    return;
                }
            } catch (Exception fallbackException) {
                LOGGER.log(Level.SEVERE, "EnrollmentDetailsServlet: fallback render failed", fallbackException);
            }
            response.sendRedirect(request.getContextPath() + "/student/my-enrollments?error=exception");
        }
    }

    private Integer resolveEnrollmentId(HttpServletRequest request) {
        String value = request.getParameter("id");
        if (value == null || value.trim().isEmpty()) {
            value = request.getParameter("enrollmentId");
        }
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Integer parseIntegerParameter(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Map<Integer, String> parseObjectiveAnswers(String rawAnswers) {
        Map<Integer, String> answers = new LinkedHashMap<>();
        if (rawAnswers == null || rawAnswers.trim().isEmpty()) {
            return answers;
        }
        String[] tokens = rawAnswers.split(";");
        for (String token : tokens) {
            if (token == null || token.trim().isEmpty() || !token.startsWith("Q")) {
                continue;
            }
            int splitIndex = token.indexOf(':');
            if (splitIndex <= 1) {
                continue;
            }
            try {
                Integer questionId = Integer.parseInt(token.substring(1, splitIndex).trim());
                String answer = token.substring(splitIndex + 1).trim();
                answers.put(questionId, answer);
            } catch (NumberFormatException ignore) {
            }
        }
        return answers;
    }

    private double computePercentage(Double score, Integer totalMarks) {
        if (score == null || totalMarks == null || totalMarks <= 0) {
            return 0.0;
        }
        return Math.round((score / totalMarks) * 1000.0) / 10.0;
    }

    private String humanizeSubmissionStatus(AssessmentSubmission submission) {
        if (submission == null || submission.getStatus() == null || submission.getStatus().trim().isEmpty()) {
            return "Awaiting Review";
        }
        String status = submission.getStatus().trim();
        if ("Graded".equalsIgnoreCase(status)) {
            return "Graded";
        }
        if ("TimedOut".equalsIgnoreCase(status)) {
            return "Timed Out";
        }
        return "Awaiting Review";
    }

    private String statusClassForSubmission(AssessmentSubmission submission) {
        if (submission == null || submission.getStatus() == null) {
            return "status-awaiting";
        }
        String status = submission.getStatus().trim();
        if ("Graded".equalsIgnoreCase(status)) {
            return "status-graded";
        }
        if ("TimedOut".equalsIgnoreCase(status)) {
            return "status-closed";
        }
        return "status-awaiting";
    }

    private String buildCourseAssessmentUrl(HttpServletRequest request, Integer enrollmentId, Integer courseId, Integer assessmentId, boolean assignment) {
        if (assignment) {
            return request.getContextPath() + "/student/enrollment-details?id=" + enrollmentId + "&tab=assessments&assessmentId=" + assessmentId;
        }
        String base = request.getContextPath() + "/courses/" + courseId + "/assessments/" + assessmentId;
        return base + "/attempt";
    }

    private Material findMaterialById(List<Material> materials, Integer materialId) {
        if (materials == null || materialId == null) {
            return null;
        }
        for (Material material : materials) {
            if (material.getMaterialId() != null && material.getMaterialId().equals(materialId)) {
                return material;
            }
        }
        return null;
    }

    private Assessment findAssessmentById(List<Assessment> assessments, Integer assessmentId) {
        if (assessments == null || assessmentId == null) {
            return null;
        }
        for (Assessment assessment : assessments) {
            if (assessment.getAssessmentId() != null && assessment.getAssessmentId().equals(assessmentId)) {
                return assessment;
            }
        }
        return null;
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
                        double threshold = resolvePassThreshold(a);
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

    private double resolvePassThreshold(Assessment a) {
        int passMarkPercent = AppSettingsService.getInt(AppSettingsService.KEY_ASSESSMENT_PASS_MARK, 70, 1, 100);
        Integer totalMarks = a != null ? a.getTotalMarks() : null;
        if (totalMarks == null || totalMarks <= 0) {
            double sumOfMarks = 0.0;
            if (a != null && a.getAssessmentId() != null) {
                try (java.sql.Connection conn = com.psm.elearning.util.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement("SELECT SUM(Marks) FROM AssessmentQuestion WHERE AssessmentID = ?")) {
                    ps.setInt(1, a.getAssessmentId());
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            sumOfMarks = rs.getDouble(1);
                        }
                    }
                } catch (Exception e) {
                    // Ignore
                }
            }
            if (sumOfMarks > 0) {
                return sumOfMarks * (passMarkPercent / 100.0);
            }
            return passMarkPercent;
        }
        return totalMarks * (passMarkPercent / 100.0);
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

    private String resolveSubmissionModeLabel(String submissionMode) {
        if (submissionMode == null) {
            return "Objective";
        }
        switch (submissionMode.trim().toLowerCase()) {
            case "file":
                return "File Upload";
            case "text":
                return "Written Response";
            case "both":
                return "Text + File";
            default:
                return "Objective";
        }
    }

    private AssessmentPlacementUtil.Placement resolvePlacement(Assessment assessment) {
        String placementType = assessment.getPlacementType() == null ? "" : assessment.getPlacementType().trim();
        if (!placementType.isEmpty()) {
            Integer placementMaterialId = assessment.getPlacementMaterialId();
            if ("afterMaterial".equals(placementType) && placementMaterialId == null) {
                placementType = "final";
            }
            return new AssessmentPlacementUtil.Placement(placementType, placementMaterialId);
        }
        return AssessmentPlacementUtil.parsePlacement(assessment.getInstructions());
    }

    private boolean isPaymentComplete(String paymentStatus) {
        if (paymentStatus == null) return false;
        String normalized = paymentStatus.trim();
        return "Paid".equalsIgnoreCase(normalized)
                || "Completed".equalsIgnoreCase(normalized)
                || "Success".equalsIgnoreCase(normalized);
    }
}






