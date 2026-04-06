package com.psm.elearning.dao;

import com.psm.elearning.model.InstructorApplication;
import java.util.List;

public interface InstructorApplicationDAO {
    InstructorApplication create(InstructorApplication application);
    InstructorApplication findById(int applicationId);
    InstructorApplication findLatestByEmail(String email);
    List<InstructorApplication> findAll();
    boolean updateStatus(int applicationId, String status, Integer reviewedBy, String adminNotes);
    int countByStatus(String status);
}