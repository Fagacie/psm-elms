package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentRetakeRequest;

import java.util.List;

public interface AssessmentRetakeRequestDAO {
    AssessmentRetakeRequest create(AssessmentRetakeRequest request);
    List<AssessmentRetakeRequest> findByAssessment(int assessmentId);
    List<AssessmentRetakeRequest> findByAssessmentAndUser(int assessmentId, int userId);
    boolean hasPending(int assessmentId, int userId);
    int countApproved(int assessmentId, int userId);
    boolean updateStatus(int requestId, String status, Integer reviewedBy);
}
