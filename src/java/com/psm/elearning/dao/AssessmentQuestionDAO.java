package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentQuestion;
import java.util.List;

public interface AssessmentQuestionDAO {
    AssessmentQuestion addQuestion(AssessmentQuestion question);
    AssessmentQuestion findById(int questionId);
    List<AssessmentQuestion> findByAssessment(int assessmentId);
    boolean delete(int questionId);
}
