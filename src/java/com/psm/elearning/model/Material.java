package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * Material entity representing course materials.
 * Matches the Material table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Material {
    @NotNull(message = "Material ID cannot be null")
    private Integer materialId;
    
    @NotNull(message = "Course ID is required")
    private Integer courseId;
    
    @NotBlank(message = "Material title is required")
    @Size(min = 2, max = 200, message = "Title must be between 2 and 200 characters")
    private String title;
    
    @Size(max = 5000, message = "Description must not exceed 5000 characters")
    private String description;
    
    @NotBlank(message = "Material type is required")
    @Pattern(regexp = "^(PDF|Video|Link|Slides)$", message = "Type must be PDF, Video, Link, or Slides")
    private String materialType;
    
    @NotBlank(message = "File path is required")
    @Size(max = 255, message = "File path must not exceed 255 characters")
    private String filePath;
    
    @NotNull(message = "UploadedBy user ID is required")
    private Integer uploadedBy;
    
    private LocalDateTime uploadDate;
    
    @Size(max = 20, message = "Version number must not exceed 20 characters")
    private String versionNumber;

    @Min(value = 1, message = "Display order must be at least 1")
    private Integer displayOrder;

    private boolean isDeleted;
    private LocalDateTime deletedAt;
    private Integer deletedBy;

    // Type constants
    public static final String TYPE_PDF = "PDF";
    public static final String TYPE_VIDEO = "Video";
    public static final String TYPE_LINK = "Link";
    public static final String TYPE_SLIDES = "Slides";
    
    // Constructors
    public Material() {}
    
    public Material(Integer materialId, Integer courseId, String title, String description,
                   String materialType, String filePath, Integer uploadedBy, LocalDateTime uploadDate,
                   String versionNumber) {
        this.materialId = materialId;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.materialType = materialType;
        this.filePath = filePath;
        this.uploadedBy = uploadedBy;
        this.uploadDate = uploadDate;
        this.versionNumber = versionNumber;
        this.isDeleted = false;
    }
    
    // Getters and Setters
    public Integer getMaterialId() { return materialId; }
    public void setMaterialId(Integer materialId) { this.materialId = materialId; }
    
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getMaterialType() { return materialType; }
    public void setMaterialType(String materialType) { this.materialType = materialType; }
    
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    
    public Integer getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(Integer uploadedBy) { this.uploadedBy = uploadedBy; }
    
    public LocalDateTime getUploadDate() { return uploadDate; }
    public void setUploadDate(LocalDateTime uploadDate) { this.uploadDate = uploadDate; }
    
    public String getVersionNumber() { return versionNumber; }
    public void setVersionNumber(String versionNumber) { this.versionNumber = versionNumber; }

    public Integer getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(Integer displayOrder) { this.displayOrder = displayOrder; }

    public boolean isDeleted() { return isDeleted; }
    public void setDeleted(boolean deleted) { isDeleted = deleted; }

    public LocalDateTime getDeletedAt() { return deletedAt; }
    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public Integer getDeletedBy() { return deletedBy; }
    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }
}






