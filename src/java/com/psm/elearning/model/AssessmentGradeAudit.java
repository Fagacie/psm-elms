package com.psm.elearning.model;

import java.time.LocalDateTime;

public class AssessmentGradeAudit {
    private Integer auditId;
    private Integer submissionId;
    private Integer assessmentId;
    private String actionType;
    private Double oldScore;
    private Double newScore;
    private String oldFeedback;
    private String newFeedback;
    private Integer gradedBy;
    private String gradedByName;
    private String gradedByEmail;
    private LocalDateTime gradedAt;
    private String note;

    public Integer getAuditId() { return auditId; }
    public void setAuditId(Integer auditId) { this.auditId = auditId; }

    public Integer getSubmissionId() { return submissionId; }
    public void setSubmissionId(Integer submissionId) { this.submissionId = submissionId; }

    public Integer getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Integer assessmentId) { this.assessmentId = assessmentId; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public Double getOldScore() { return oldScore; }
    public void setOldScore(Double oldScore) { this.oldScore = oldScore; }

    public Double getNewScore() { return newScore; }
    public void setNewScore(Double newScore) { this.newScore = newScore; }

    public String getOldFeedback() { return oldFeedback; }
    public void setOldFeedback(String oldFeedback) { this.oldFeedback = oldFeedback; }

    public String getNewFeedback() { return newFeedback; }
    public void setNewFeedback(String newFeedback) { this.newFeedback = newFeedback; }

    public Integer getGradedBy() { return gradedBy; }
    public void setGradedBy(Integer gradedBy) { this.gradedBy = gradedBy; }

    public String getGradedByName() { return gradedByName; }
    public void setGradedByName(String gradedByName) { this.gradedByName = gradedByName; }

    public String getGradedByEmail() { return gradedByEmail; }
    public void setGradedByEmail(String gradedByEmail) { this.gradedByEmail = gradedByEmail; }

    public LocalDateTime getGradedAt() { return gradedAt; }
    public void setGradedAt(LocalDateTime gradedAt) { this.gradedAt = gradedAt; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
