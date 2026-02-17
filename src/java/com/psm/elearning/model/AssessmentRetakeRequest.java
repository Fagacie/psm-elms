package com.psm.elearning.model;

import java.time.LocalDateTime;

public class AssessmentRetakeRequest {
    private Integer requestId;
    private Integer assessmentId;
    private Integer userId;
    private String reason;
    private String status;
    private LocalDateTime requestedAt;
    private LocalDateTime reviewedAt;
    private Integer reviewedBy;

    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }

    public Integer getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Integer assessmentId) { this.assessmentId = assessmentId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }

    public LocalDateTime getReviewedAt() { return reviewedAt; }
    public void setReviewedAt(LocalDateTime reviewedAt) { this.reviewedAt = reviewedAt; }

    public Integer getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(Integer reviewedBy) { this.reviewedBy = reviewedBy; }
}
