package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Course entity representing course attributes.
 * Matches the Course table schema.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Course {
    
    // Default constructor
    public Course() {}
    
    // Constructor with all fields
    public Course(Integer courseId, String courseName, String description, String category,
                  Integer duration, BigDecimal courseFee, String level, Integer createdBy,
                  Integer approvedBy, LocalDateTime createdAt, LocalDateTime updatedAt, String status) {
        this.courseId = courseId;
        this.courseName = courseName;
        this.description = description;
        this.category = category;
        this.duration = duration;
        this.courseFee = courseFee;
        this.level = level;
        this.createdBy = createdBy;
        this.approvedBy = approvedBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.status = status;
    }
    @NotNull(message = "Course ID cannot be null")
    private Integer courseId;
    
    @NotBlank(message = "Course name is required")
    @Size(min = 3, max = 200, message = "Course name must be between 3 and 200 characters")
    private String courseName;
    
    @Size(max = 5000, message = "Description must not exceed 5000 characters")
    private String description;
    
    @Size(max = 100, message = "Category must not exceed 100 characters")
    private String category;
    
    @Min(value = 1, message = "Duration must be at least 1 day")
    @Max(value = 36500, message = "Duration must not exceed 36500 days")
    private Integer duration;
    
    @NotNull(message = "Course fee is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Course fee must be zero or greater")
    @DecimalMax(value = "999999.99", message = "Course fee must not exceed 999999.99")
    private BigDecimal courseFee;
    
    @NotBlank(message = "Level is required")
    @Pattern(regexp = "^(Beginner|Intermediate|Advanced)$", message = "Level must be Beginner, Intermediate, or Advanced")
    private String level;
    
    private Integer createdBy;
    
    private Integer approvedBy;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    @NotBlank(message = "Status is required")
    @Pattern(regexp = "^(Pending|Approved|Archived)$", message = "Status must be Pending, Approved, or Archived")
    private String status;
    
    @Size(max = 255, message = "Course banner URL must not exceed 255 characters")
    private String courseBanner;

    /**
     * Tracks the async Cloudinary upload state for the course banner.
     * Values: "pending" (upload queued), "uploaded" (complete), "failed" (upload error).
     * Null means no banner upload has been initiated.
     */
    private String bannerUploadStatus;

    // Banner upload status constants
    public static final String BANNER_STATUS_PENDING  = "pending";
    public static final String BANNER_STATUS_UPLOADED = "uploaded";
    public static final String BANNER_STATUS_FAILED   = "failed";

    // Status constants
    public static final String LEVEL_BEGINNER = "Beginner";
    public static final String LEVEL_INTERMEDIATE = "Intermediate";
    public static final String LEVEL_ADVANCED = "Advanced";

    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_APPROVED = "Approved";
    public static final String STATUS_ARCHIVED = "Archived";
    
    // Getters and Setters
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public Integer getDuration() { return duration; }
    public void setDuration(Integer duration) { this.duration = duration; }
    
    public BigDecimal getCourseFee() { return courseFee; }
    public void setCourseFee(BigDecimal courseFee) { this.courseFee = courseFee; }
    
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    
    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }
    
    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCourseBanner() { return courseBanner; }
    public void setCourseBanner(String courseBanner) { this.courseBanner = courseBanner; }

    public String getBannerUploadStatus() { return bannerUploadStatus; }
    public void setBannerUploadStatus(String bannerUploadStatus) { this.bannerUploadStatus = bannerUploadStatus; }

    // Duration is stored in days; these helpers keep UI expressive (days/weeks/months).
    public String getDurationUnitGuess() {
        if (duration == null || duration <= 0) {
            return "days";
        }
        if (duration % 30 == 0) {
            return "months";
        }
        if (duration % 7 == 0) {
            return "weeks";
        }
        return "days";
    }

    public Integer getDurationValueForDisplay() {
        if (duration == null || duration <= 0) {
            return duration;
        }
        if (duration % 30 == 0) {
            return duration / 30;
        }
        if (duration % 7 == 0) {
            return duration / 7;
        }
        return duration;
    }

    public String getDisplayDuration() {
        if (duration == null || duration <= 0) {
            return "-";
        }
        String unit = getDurationUnitGuess();
        Integer value = getDurationValueForDisplay();
        String singular = "day";
        if ("weeks".equals(unit)) {
            singular = "week";
        } else if ("months".equals(unit)) {
            singular = "month";
        }
        String label = value != null && value == 1 ? singular : unit;
        return value + " " + label;
    }
}

