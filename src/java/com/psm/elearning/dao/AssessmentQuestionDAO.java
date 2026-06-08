package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentQuestion;
import java.util.List;

public interface AssessmentQuestionDAO {
    AssessmentQuestion addQuestion(AssessmentQuestion question);
    AssessmentQuestion findById(int questionId);
    List<AssessmentQuestion> findByAssessment(int assessmentId);
    List<AssessmentQuestion> findByAssessmentIds(List<Integer> assessmentIds);
    boolean updateQuestion(AssessmentQuestion question);
    boolean swapQuestionContent(int firstQuestionId, int secondQuestionId);
    boolean delete(int questionId);
}
