package com.psm.elearning.service;

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

import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;

/**
 * Centralized enrollment state synchronization.
 *
 * Recomputes payment sync, learning progress, completion status,
 * and certificate eligibility from canonical tables, then persists
 * normalized state back to Enrollment.
 */
public class EnrollmentStateSyncService {

    private final EnrollmentDAO enrollmentDAO;
    private final PaymentDAO paymentDAO;
    private final AssessmentDAO assessmentDAO;
    private final AssessmentSubmissionDAO submissionDAO;
    private final MaterialDAO materialDAO;
    private final MaterialProgressDAO materialProgressDAO;

    public EnrollmentStateSyncService() {
        this.enrollmentDAO = new EnrollmentDAOImpl();
        this.paymentDAO = new PaymentDAOImpl();
        this.assessmentDAO = new AssessmentDAOImpl();
        this.submissionDAO = new AssessmentSubmissionDAOImpl();
        this.materialDAO = new MaterialDAOImpl();
        this.materialProgressDAO = new MaterialProgressDAOImpl();
    }

    public SyncResult syncEnrollmentState(Enrollment enrollment) {
        if (enrollment == null || enrollment.getEnrollmentId() == null
                || enrollment.getCourseId() == null || enrollment.getUserId() == null) {
            return new SyncResult(false, false, false, false, 0, 0, 0, 0, 0,
                    false, false, "Pending", null, "Not Started", "Pending");
        }

        Payment payment = paymentDAO.getPaymentByEnrollmentId(enrollment.getEnrollmentId());
        String paymentStatus = payment != null && payment.getStatus() != null
                ? payment.getStatus()
                : (enrollment.getPaymentStatus() != null ? enrollment.getPaymentStatus() : "Pending");
        String paymentRef = payment != null ? payment.getPaystackReference() : enrollment.getPaymentRef();
        boolean paid = "Paid".equalsIgnoreCase(paymentStatus);

        enrollmentDAO.updatePaymentStatus(enrollment.getEnrollmentId(), paymentStatus, paymentRef);
        enrollment.setPaymentStatus(paymentStatus);
        enrollment.setPaymentRef(paymentRef);

        List<Material> materials = materialDAO.findByCourse(enrollment.getCourseId());
        if (materials == null) materials = new ArrayList<>();
        int totalMaterials = materials.size();
        int viewedMaterials = materialProgressDAO.countViewedByCourse(enrollment.getUserId(), enrollment.getCourseId());
        double materialRatio = totalMaterials == 0 ? 1.0 : Math.min(1.0, (double) viewedMaterials / totalMaterials);
        int completionThresholdPercent = AppSettingsService.getInt(
                AppSettingsService.KEY_LEARNING_COMPLETION_PERCENT, 100, 1, 100
        );

        List<Assessment> assessments = assessmentDAO.findByCourse(enrollment.getCourseId());
        if (assessments == null) assessments = new ArrayList<>();
        int totalAssessments = assessments.size();
        int passedAssessments = 0;
        double assessmentEngagementPoints = 0.0;
        boolean passedAllAssessments = true;

        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), enrollment.getUserId());
            AssessmentProgressState progressState = resolveAssessmentProgress(assessment, submissions);
            assessmentEngagementPoints += progressState.getEngagementWeight();
            if (progressState.isPassed()) {
                passedAssessments++;
            } else {
                passedAllAssessments = false;
            }
        }

        double assessmentRatio = totalAssessments == 0 ? 1.0 : Math.min(1.0, assessmentEngagementPoints / totalAssessments);
        // Progress = purely materials-based: viewed / total × 100.
        // Assessment data is used for completion/certificate eligibility only.
        int progressPercent;
        if (totalMaterials == 0) {
            // No materials — progress determined by assessments only
            progressPercent = totalAssessments == 0 ? 100
                    : (int) Math.round(assessmentRatio * 100.0);
        } else {
            progressPercent = (int) Math.round(materialRatio * 100.0);
        }
        progressPercent = Math.max(0, Math.min(100, progressPercent));

        boolean viewedAllMaterials = totalMaterials == 0
                || (materialRatio * 100.0) >= completionThresholdPercent;
        boolean passedRequiredAssessments = totalAssessments == 0 || passedAssessments >= totalAssessments;
        boolean completed = viewedAllMaterials && passedRequiredAssessments;
        String completionStatus = completed ? "Completed" : (progressPercent > 0 ? "In Progress" : "Not Started");
        String enrollmentStatus = completed ? "Completed" : "Enrolled";

        enrollmentDAO.updateLearningProgress(enrollment.getEnrollmentId(), progressPercent, completionStatus, enrollmentStatus);
        enrollment.setProgress(progressPercent);
        enrollment.setCompletionStatus(completionStatus);
        enrollment.setStatus(enrollmentStatus);

        boolean eligibleForCertificate = paid && viewedAllMaterials && passedRequiredAssessments;

        return new SyncResult(
                paid,
                passedAllAssessments,
                completed,
                eligibleForCertificate,
                progressPercent,
                viewedMaterials,
                totalMaterials,
                passedAssessments,
                totalAssessments,
                viewedAllMaterials,
                passedRequiredAssessments,
                paymentStatus,
                paymentRef,
                completionStatus,
                enrollmentStatus
        );
    }

    public static AssessmentProgressState resolveAssessmentProgress(Assessment assessment, List<AssessmentSubmission> submissions) {
        if (assessment == null || submissions == null || submissions.isEmpty()) {
            return new AssessmentProgressState(false, false, 0.0);
        }

        boolean submitted = false;
        boolean graded = false;
        boolean passed = false;

        for (AssessmentSubmission submission : submissions) {
            if (submission == null) continue;
            if ("TimedOut".equalsIgnoreCase(submission.getStatus())) {
                continue;
            }
            submitted = true;
            if (submission.getScore() != null) {
                graded = true;
                double threshold = resolvePassThresholdStatic(assessment);
                if (submission.getScore() >= threshold) {
                    passed = true;
                    break;
                }
            }
        }

        if (passed) {
            return new AssessmentProgressState(true, true, 1.0);
        }


        if (submitted) {
            return new AssessmentProgressState(true, false, 0.0);
        }
        return new AssessmentProgressState(false, false, 0.0);
    }

    private static double resolvePassThresholdStatic(Assessment assessment) {
        int passMarkPercent = AppSettingsService.getInt(
                AppSettingsService.KEY_ASSESSMENT_PASS_MARK, 70, 1, 100
        );
        Integer totalMarks = assessment != null ? assessment.getTotalMarks() : null;
        if (totalMarks == null || totalMarks <= 0) {
            double sumOfMarks = 0.0;
            if (assessment != null && assessment.getAssessmentId() != null) {
                try (java.sql.Connection conn = com.psm.elearning.util.DBConnection.getConnection();
                     java.sql.PreparedStatement ps = conn.prepareStatement("SELECT SUM(Marks) FROM AssessmentQuestion WHERE AssessmentID = ?")) {
                    ps.setInt(1, assessment.getAssessmentId());
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            sumOfMarks = rs.getDouble(1);
                        }
                    }
                } catch (Exception e) {
                    // Ignore
                }
            }

            if (sumOfMarks <= 0) {
                int questionCount = 0;
                if (assessment != null && assessment.getAssessmentId() != null) {
                    try (java.sql.Connection conn = com.psm.elearning.util.DBConnection.getConnection();
                         java.sql.PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM AssessmentQuestion WHERE AssessmentID = ?")) {
                        ps.setInt(1, assessment.getAssessmentId());
                        try (java.sql.ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                questionCount = rs.getInt(1);
                            }
                        }
                    } catch (Exception e) {
                        // Ignore
                    }
                }
                if (questionCount > 0) {
                    sumOfMarks = questionCount * 1.0;
                }
            }

            if (sumOfMarks > 0) {
                return sumOfMarks * (passMarkPercent / 100.0);
            }
            return passMarkPercent;
        }
        return totalMarks * (passMarkPercent / 100.0);
    }

    public static class SyncResult {
        private final boolean paid;
        private final boolean passedAllAssessments;
        private final boolean completed;
        private final boolean eligibleForCertificate;
        private final int progressPercent;
        private final int viewedMaterials;
        private final int totalMaterials;
        private final int passedAssessments;
        private final int totalAssessments;
        private final boolean viewedAllMaterials;
        private final boolean passedRequiredAssessments;
        private final String paymentStatus;
        private final String paymentRef;
        private final String completionStatus;
        private final String enrollmentStatus;

        public SyncResult(boolean paid,
                          boolean passedAllAssessments,
                          boolean completed,
                          boolean eligibleForCertificate,
                          int progressPercent,
                          int viewedMaterials,
                          int totalMaterials,
                          int passedAssessments,
                          int totalAssessments,
                          boolean viewedAllMaterials,
                          boolean passedRequiredAssessments,
                          String paymentStatus,
                          String paymentRef,
                          String completionStatus,
                          String enrollmentStatus) {
            this.paid = paid;
            this.passedAllAssessments = passedAllAssessments;
            this.completed = completed;
            this.eligibleForCertificate = eligibleForCertificate;
            this.progressPercent = progressPercent;
            this.viewedMaterials = viewedMaterials;
            this.totalMaterials = totalMaterials;
            this.passedAssessments = passedAssessments;
            this.totalAssessments = totalAssessments;
            this.viewedAllMaterials = viewedAllMaterials;
            this.passedRequiredAssessments = passedRequiredAssessments;
            this.paymentStatus = paymentStatus;
            this.paymentRef = paymentRef;
            this.completionStatus = completionStatus;
            this.enrollmentStatus = enrollmentStatus;
        }

        public boolean isPaid() { return paid; }
        public boolean isPassedAllAssessments() { return passedAllAssessments; }
        public boolean isCompleted() { return completed; }
        public boolean isEligibleForCertificate() { return eligibleForCertificate; }
        public int getProgressPercent() { return progressPercent; }
        public int getViewedMaterials() { return viewedMaterials; }
        public int getTotalMaterials() { return totalMaterials; }
        public int getPassedAssessments() { return passedAssessments; }
        public int getTotalAssessments() { return totalAssessments; }
        public String getPaymentStatus() { return paymentStatus; }
        public String getPaymentRef() { return paymentRef; }
        public String getCompletionStatus() { return completionStatus; }
        public String getEnrollmentStatus() { return enrollmentStatus; }

        public boolean hasViewedAllMaterials() {
            return viewedAllMaterials;
        }

        public boolean isViewedAllMaterials() {
            return hasViewedAllMaterials();
        }

        public boolean hasPassedRequiredAssessments() {
            return passedRequiredAssessments;
        }

        public boolean isPassedRequiredAssessments() {
            return hasPassedRequiredAssessments();
        }

        public List<String> getMissingRequirements() {
            List<String> missing = new ArrayList<>();
            if (!paid) {
                missing.add("payment");
            }
            if (!hasViewedAllMaterials()) {
                missing.add("materials");
            }
            if (!hasPassedRequiredAssessments()) {
                missing.add("assessments");
            }
            return missing;
        }

        public String getBlockingReasonSummary() {
            List<String> missing = getMissingRequirements();
            if (missing.isEmpty()) {
                return "All certificate requirements are complete.";
            }
            StringJoiner joiner = new StringJoiner(", ");
            if (missing.contains("payment")) {
                joiner.add("payment not confirmed");
            }
            if (missing.contains("materials")) {
                joiner.add("not all materials viewed");
            }
            if (missing.contains("assessments")) {
                joiner.add("not all required assessments passed");
            }
            return "Certificate requirements pending: " + joiner;
        }
    }

    public static class AssessmentProgressState {
        private final boolean attempted;
        private final boolean passed;
        private final double engagementWeight;

        public AssessmentProgressState(boolean attempted, boolean passed, double engagementWeight) {
            this.attempted = attempted;
            this.passed = passed;
            this.engagementWeight = engagementWeight;
        }

        public boolean isAttempted() { return attempted; }
        public boolean isPassed() { return passed; }
        public double getEngagementWeight() { return engagementWeight; }
    }
}
