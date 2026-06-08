package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentRetakeRequest;

import java.util.List;

public interface AssessmentRetakeRequestDAO {
    AssessmentRetakeRequest create(AssessmentRetakeRequest request);
    AssessmentRetakeRequest findById(int requestId);
    List<AssessmentRetakeRequest> findByAssessment(int assessmentId);
    List<AssessmentRetakeRequest> findByAssessmentIds(List<Integer> assessmentIds);
    List<AssessmentRetakeRequest> findByAssessmentAndUser(int assessmentId, int userId);
    List<AssessmentRetakeRequest> findByUser(int userId);
    boolean hasPending(int assessmentId, int userId);
    int countApproved(int assessmentId, int userId);
    boolean updateStatus(int requestId, String status, Integer reviewedBy);
}
