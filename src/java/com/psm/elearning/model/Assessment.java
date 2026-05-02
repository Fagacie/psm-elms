package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * Assessment entity representing assessments linked to courses.
 * Matches the Assessment table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Assessment {
    @NotNull(message = "Assessment ID cannot be null")
    private Integer assessmentId;
    
    @NotNull(message = "Course ID is required")
    private Integer courseId;
    
    @NotBlank(message = "Assessment title is required")
    @Size(min = 2, max = 200, message = "Title must be between 2 and 200 characters")
    private String title;
    
    @NotBlank(message = "Assessment type is required")
    @Pattern(regexp = "^(Quiz|Exam|Assignment)$", message = "Type must be Quiz, Exam, or Assignment")
    private String type;

    @Pattern(regexp = "^(auto|manual)$", message = "Grading mode must be auto or manual")
    private String gradingMode;

    @Pattern(regexp = "^(file|text|both)$", message = "Submission mode must be file, text, or both")
    private String submissionMode;
    
    @Min(value = 1, message = "Duration must be at least 1 minute")
    @Max(value = 480, message = "Duration must not exceed 480 minutes (8 hours)")
    private Integer duration;
    
    @Min(value = 1, message = "Total marks must be at least 1")
    @Max(value = 1000, message = "Total marks must not exceed 1000")
    private Integer totalMarks;
    
    @Size(max = 5000, message = "Instructions must not exceed 5000 characters")
    private String instructions;

    @Pattern(regexp = "^(final|afterMaterial)$", message = "Placement type must be final or afterMaterial")
    private String placementType;

    private Integer placementMaterialId;

    @Min(value = 1, message = "Max attempts must be at least 1")
    @Max(value = 10, message = "Max attempts must not exceed 10")
    private Integer maxAttempts;

    private LocalDateTime createdAt;
    
    @NotNull(message = "CreatedBy user ID is required")
    private Integer createdBy;

    // Type constants
    public static final String TYPE_QUIZ = "Quiz";
    public static final String TYPE_EXAM = "Exam";
    public static final String TYPE_ASSIGNMENT = "Assignment";
    
    // Constructors
    public Assessment() {}
    
    public Assessment(Integer assessmentId, Integer courseId, String title, String type,
                     String gradingMode,
                     String submissionMode,
                     Integer duration, Integer totalMarks, String instructions, Integer maxAttempts,
                     LocalDateTime createdAt, Integer createdBy) {
        this.assessmentId = assessmentId;
        this.courseId = courseId;
        this.title = title;
        this.type = type;
        this.gradingMode = gradingMode;
        this.submissionMode = submissionMode;
        this.duration = duration;
        this.totalMarks = totalMarks;
        this.instructions = instructions;
        this.maxAttempts = maxAttempts;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
    }
    
    // Getters and Setters
    public Integer getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Integer assessmentId) { this.assessmentId = assessmentId; }
    
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getGradingMode() { return gradingMode; }
    public void setGradingMode(String gradingMode) { this.gradingMode = gradingMode; }

    public String getSubmissionMode() { return submissionMode; }
    public void setSubmissionMode(String submissionMode) { this.submissionMode = submissionMode; }
    
    public Integer getDuration() { return duration; }
    public void setDuration(Integer duration) { this.duration = duration; }
    
    public Integer getTotalMarks() { return totalMarks; }
    public void setTotalMarks(Integer totalMarks) { this.totalMarks = totalMarks; }
    
    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public String getPlacementType() { return placementType; }
    public void setPlacementType(String placementType) { this.placementType = placementType; }

    public Integer getPlacementMaterialId() { return placementMaterialId; }
    public void setPlacementMaterialId(Integer placementMaterialId) { this.placementMaterialId = placementMaterialId; }

    public Integer getMaxAttempts() { return maxAttempts; }
    public void setMaxAttempts(Integer maxAttempts) { this.maxAttempts = maxAttempts; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
}






