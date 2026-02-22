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
                    "Pending", null, "Not Started", "Pending");
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

        List<Assessment> assessments = assessmentDAO.findByCourse(enrollment.getCourseId());
        if (assessments == null) assessments = new ArrayList<>();
        int totalAssessments = assessments.size();
        int passedAssessments = 0;
        boolean passedAllAssessments = true;

        for (Assessment assessment : assessments) {
            List<AssessmentSubmission> submissions = submissionDAO.findByAssessmentAndUser(assessment.getAssessmentId(), enrollment.getUserId());
            boolean passed = false;
            if (submissions != null) {
                for (AssessmentSubmission s : submissions) {
                    if (s.getScore() == null) continue;
                    if ("TimedOut".equalsIgnoreCase(s.getStatus())) continue;
                    double threshold = resolvePassThreshold(assessment.getTotalMarks());
                    if (s.getScore() >= threshold) {
                        passed = true;
                        break;
                    }
                }
            }
            if (passed) {
                passedAssessments++;
            } else {
                passedAllAssessments = false;
            }
        }

        double assessmentRatio = totalAssessments == 0 ? 1.0 : Math.min(1.0, (double) passedAssessments / totalAssessments);
        int progressPercent = (int) Math.round((materialRatio * 60.0) + (assessmentRatio * 40.0));
        progressPercent = Math.max(0, Math.min(100, progressPercent));

        boolean completed = progressPercent >= 100 && passedAllAssessments;
        String completionStatus = completed ? "Completed" : (progressPercent > 0 ? "In Progress" : "Not Started");
        String enrollmentStatus = completed ? "Completed" : "Enrolled";

        enrollmentDAO.updateLearningProgress(enrollment.getEnrollmentId(), progressPercent, completionStatus, enrollmentStatus);
        enrollment.setProgress(progressPercent);
        enrollment.setCompletionStatus(completionStatus);
        enrollment.setStatus(enrollmentStatus);

        boolean eligibleForCertificate = paid && completed && passedAllAssessments;

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
                paymentStatus,
                paymentRef,
                completionStatus,
                enrollmentStatus
        );
    }

    private double resolvePassThreshold(Integer totalMarks) {
        if (totalMarks == null || totalMarks <= 0) {
            return 50.0;
        }
        return totalMarks * 0.5;
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
    }
}
