package com.psm.elearning.dao;

import com.psm.elearning.model.Assessment;
import java.util.List;

public interface AssessmentDAO {
    Assessment create(Assessment assessment);
    Assessment findById(int assessmentId);
    Assessment findAnyById(int assessmentId);
    List<Assessment> findByCourse(int courseId);
    List<Assessment> findDeletedByCourse(int courseId);
    boolean update(Assessment assessment);
    boolean delete(int assessmentId);
    boolean archive(int assessmentId, Integer archivedBy);
    boolean restore(int assessmentId);
}
