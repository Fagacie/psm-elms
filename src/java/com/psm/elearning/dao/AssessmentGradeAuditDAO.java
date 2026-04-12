package com.psm.elearning.dao;

import com.psm.elearning.model.AssessmentGradeAudit;

import java.util.List;

public interface AssessmentGradeAuditDAO {
    boolean record(AssessmentGradeAudit audit);
    List<AssessmentGradeAudit> findBySubmission(int submissionId);
}
