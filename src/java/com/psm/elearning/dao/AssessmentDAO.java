package com.psm.elearning.dao;

import com.psm.elearning.model.Assessment;
import java.util.List;

public interface AssessmentDAO {
    Assessment create(Assessment assessment);
    Assessment findById(int assessmentId);
    List<Assessment> findByCourse(int courseId);
    boolean update(Assessment assessment);
}
