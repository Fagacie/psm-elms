package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentSubmission;
import java.util.List;

public interface AssessmentSubmissionDAO {
    AssessmentSubmission submit(AssessmentSubmission submission);
    AssessmentSubmission findById(int submissionId);
    List<AssessmentSubmission> findByAssessment(int assessmentId);
    List<AssessmentSubmission> findByAssessmentIds(List<Integer> assessmentIds);
    List<AssessmentSubmission> findByAssessmentAndUser(int assessmentId, int userId);
    List<AssessmentSubmission> findByUser(int userId);
    boolean gradeSubmission(int submissionId, Double score, String feedback);
}
