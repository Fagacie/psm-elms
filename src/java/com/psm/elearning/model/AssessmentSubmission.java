package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * AssessmentSubmission entity representing user submissions.
 * Matches the AssessmentSubmission table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class AssessmentSubmission {
    @NotNull(message = "Submission ID cannot be null")
    private Integer submissionId;
    
    @NotNull(message = "Assessment ID is required")
    private Integer assessmentId;
    
    @NotNull(message = "User ID is required")
    private Integer userId;
    
    @Size(max = 255, message = "Answers file path must not exceed 255 characters")
    private String answersFilePath;
    
    @DecimalMin(value = "0.0", message = "Score must be >= 0")
    @DecimalMax(value = "1000.0", message = "Score must not exceed 1000")
    private Double score;
    
    @Min(value = 1, message = "Attempt number must be at least 1")
    @Max(value = 10, message = "Attempt number must not exceed 10")
    private Integer attemptNumber;
    
    private LocalDateTime submitDate;
    
    // Constructors
    public AssessmentSubmission() {}
    
    public AssessmentSubmission(Integer submissionId, Integer assessmentId, Integer userId,
                               String answersFilePath, Double score, Integer attemptNumber,
                               LocalDateTime submitDate) {
        this.submissionId = submissionId;
        this.assessmentId = assessmentId;
        this.userId = userId;
        this.answersFilePath = answersFilePath;
        this.score = score;
        this.attemptNumber = attemptNumber;
        this.submitDate = submitDate;
    }
    
    // Getters and Setters
    public Integer getSubmissionId() { return submissionId; }
    public void setSubmissionId(Integer submissionId) { this.submissionId = submissionId; }
    
    public Integer getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Integer assessmentId) { this.assessmentId = assessmentId; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getAnswersFilePath() { return answersFilePath; }
    public void setAnswersFilePath(String answersFilePath) { this.answersFilePath = answersFilePath; }
    
    public Double getScore() { return score; }
    public void setScore(Double score) { this.score = score; }
    
    public Integer getAttemptNumber() { return attemptNumber; }
    public void setAttemptNumber(Integer attemptNumber) { this.attemptNumber = attemptNumber; }
    
    public LocalDateTime getSubmitDate() { return submitDate; }
    public void setSubmitDate(LocalDateTime submitDate) { this.submitDate = submitDate; }
}






