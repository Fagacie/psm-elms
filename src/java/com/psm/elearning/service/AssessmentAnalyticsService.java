package com.psm.elearning.service;

import com.psm.elearning.dao.AssessmentDAO;
import com.psm.elearning.dao.AssessmentQuestionDAO;
import com.psm.elearning.dao.AssessmentSubmissionDAO;
import com.psm.elearning.dao.EnrollmentDAO;
import com.psm.elearning.model.Assessment;
import com.psm.elearning.model.AssessmentQuestion;
import com.psm.elearning.model.AssessmentSubmission;
import com.psm.elearning.model.Enrollment;

import java.util.*;

public class AssessmentAnalyticsService {

    private final AssessmentDAO assessmentDAO;
    private final AssessmentSubmissionDAO submissionDAO;
    private final AssessmentQuestionDAO questionDAO;
    private final EnrollmentDAO enrollmentDAO;

    public AssessmentAnalyticsService(AssessmentDAO assessmentDAO, AssessmentSubmissionDAO submissionDAO,
                                      AssessmentQuestionDAO questionDAO, EnrollmentDAO enrollmentDAO) {
        this.assessmentDAO = assessmentDAO;
        this.submissionDAO = submissionDAO;
        this.questionDAO = questionDAO;
        this.enrollmentDAO = enrollmentDAO;
    }

    public static class CourseAssessmentMetrics {
        public Map<Integer, Integer> submissionCountByAssessmentId = new LinkedHashMap<>();
        public Map<Integer, Integer> questionCountByAssessmentId = new LinkedHashMap<>();
        public Map<Integer, Integer> gradedCountByAssessmentId = new LinkedHashMap<>();
        public Map<Integer, Integer> pendingCountByAssessmentId = new LinkedHashMap<>();
        public Map<Integer, Double> averageScoreByAssessmentId = new LinkedHashMap<>();
        public Map<Integer, String> statusByAssessmentId = new LinkedHashMap<>();
        public int draftAssessmentCount = 0;
        public int activeAssessmentCount = 0;
        public int closedAssessmentCount = 0;
        public int pendingGradingAssessmentCount = 0;
    }

    public CourseAssessmentMetrics calculateMetricsForCourseAssessments(List<Assessment> assessments) {
        CourseAssessmentMetrics metrics = new CourseAssessmentMetrics();

        for (Assessment assessment : assessments) {
            if (assessment == null) continue;
            Integer assessmentId = assessment.getAssessmentId();
            
            List<AssessmentQuestion> questions = questionDAO.findByAssessment(assessmentId);
            int questionCount = questions == null ? 0 : questions.size();
            
            List<AssessmentSubmission> submissions = submissionDAO.findByAssessment(assessmentId);
            if (submissions == null) submissions = new ArrayList<>();
            int submissionCount = submissions.size();
            
            int gradedCount = 0;
            int pendingCount = 0;
            double earned = 0.0;
            int scoredCount = 0;

            for (AssessmentSubmission submission : submissions) {
                if (submission == null) continue;
                if (submission.getScore() != null) {
                    gradedCount++;
                    earned += submission.getScore();
                    scoredCount++;
                } else {
                    pendingCount++;
                }
            }

            metrics.submissionCountByAssessmentId.put(assessmentId, submissionCount);
            metrics.questionCountByAssessmentId.put(assessmentId, questionCount);
            metrics.gradedCountByAssessmentId.put(assessmentId, gradedCount);
            metrics.pendingCountByAssessmentId.put(assessmentId, pendingCount);
            metrics.averageScoreByAssessmentId.put(assessmentId, scoredCount > 0 ? earned / scoredCount : null);
            
            String workflowStatus = resolveAssessmentWorkflowStatus(assessment);
            metrics.statusByAssessmentId.put(assessmentId, workflowStatus);
            
            if ("Draft".equalsIgnoreCase(workflowStatus)) {
                metrics.draftAssessmentCount++;
            } else if ("Active".equalsIgnoreCase(workflowStatus) || "Published".equalsIgnoreCase(workflowStatus)) {
                metrics.activeAssessmentCount++;
            } else {
                metrics.closedAssessmentCount++;
            }
            if (pendingCount > 0) {
                metrics.pendingGradingAssessmentCount++;
            }
        }
        
        return metrics;
    }

    public static class AssessmentDetailedAnalytics {
        public int totalSubmissions;
        public int gradedSubmissions;
        public int pendingSubmissions;
        public Double averageScore;
        public Double topScore;
        public Double lowScore;
        public double completionRate;
        public Map<Integer, String> submissionWorkflowStatus = new LinkedHashMap<>();
        public List<Map<String, Object>> rosterRows = new ArrayList<>();
    }

    public AssessmentDetailedAnalytics calculateDetailedAnalytics(Assessment assessment, List<AssessmentSubmission> submissions, List<Enrollment> courseEnrollments) {
        AssessmentDetailedAnalytics analytics = new AssessmentDetailedAnalytics();
        
        int gradedCount = 0;
        int pendingCount = 0;
        double scoreTotal = 0.0;
        int scoredCount = 0;
        Double topScore = null;
        Double lowScore = null;

        Map<Integer, Integer> submissionCountByUserId = new LinkedHashMap<>();
        Map<Integer, AssessmentSubmission> latestSubmissionByUserId = new LinkedHashMap<>();

        for (AssessmentSubmission submission : submissions) {
            if (submission == null) continue;
            
            if (submission.getSubmissionId() != null) {
                analytics.submissionWorkflowStatus.put(submission.getSubmissionId(), resolveSubmissionWorkflowStatus(submission, assessment));
            }
            
            if (submission.getUserId() != null) {
                submissionCountByUserId.put(submission.getUserId(), submissionCountByUserId.getOrDefault(submission.getUserId(), 0) + 1);
                AssessmentSubmission currentLatest = latestSubmissionByUserId.get(submission.getUserId());
                if (currentLatest == null || (submission.getSubmissionId() != null && currentLatest.getSubmissionId() != null && submission.getSubmissionId() > currentLatest.getSubmissionId())) {
                    latestSubmissionByUserId.put(submission.getUserId(), submission);
                }
            }

            if (submission.getScore() != null) {
                gradedCount++;
                scoreTotal += submission.getScore();
                scoredCount++;
                if (topScore == null || submission.getScore() > topScore) {
                    topScore = submission.getScore();
                }
                if (lowScore == null || submission.getScore() < lowScore) {
                    lowScore = submission.getScore();
                }
            } else {
                pendingCount++;
            }
        }

        analytics.totalSubmissions = submissions.size();
        analytics.gradedSubmissions = gradedCount;
        analytics.pendingSubmissions = pendingCount;
        analytics.averageScore = scoredCount > 0 ? scoreTotal / scoredCount : null;
        analytics.topScore = topScore;
        analytics.lowScore = lowScore;
        analytics.completionRate = analytics.totalSubmissions > 0 ? (gradedCount * 100.0) / analytics.totalSubmissions : 0.0;

        // Build roster rows
        if (courseEnrollments != null) {
            for (Enrollment enrollment : courseEnrollments) {
                if (enrollment == null || enrollment.getUserId() == null) continue;
                int count = submissionCountByUserId.getOrDefault(enrollment.getUserId(), 0);
                AssessmentSubmission latest = latestSubmissionByUserId.get(enrollment.getUserId());
                
                String statusLabel = count == 0 ? "Not started" : (latest != null && latest.getScore() != null ? "Graded" : "Attempted");
                String statusClass = count == 0 ? "is-muted" : (latest != null && latest.getScore() != null ? "is-success" : "is-warn");
                
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("studentName", enrollment.getStudentName());
                row.put("studentEmail", enrollment.getStudentEmail());
                row.put("studentStatusLabel", statusLabel);
                row.put("studentStatusClass", statusClass);
                row.put("submissionCount", count);
                row.put("latestSubmission", latest);
                analytics.rosterRows.add(row);
            }
        }

        return analytics;
    }

    private String resolveAssessmentWorkflowStatus(Assessment assessment) {
        if (assessment == null) return Assessment.STATUS_DRAFT;
        String status = assessment.getStatus();
        return (status != null && !status.isEmpty()) ? status : Assessment.STATUS_DRAFT;
    }

    private String resolveSubmissionWorkflowStatus(AssessmentSubmission submission, Assessment assessment) {
        if (submission == null) return "Unknown";
        if (submission.getScore() != null) return "Graded";
        if ("Assignment".equalsIgnoreCase(assessment.getType())) return "Submitted";
        return "Pending Grade";
    }
}
