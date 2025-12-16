package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

/**
 * Instructor entity representing instructor-specific attributes.
 * Matches the Instructor table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Instructor {
    @NotNull(message = "User ID cannot be null")
    private Integer userId;
    
    @Size(max = 150, message = "Specialization must not exceed 150 characters")
    private String specialization;
    
    @Min(value = 0, message = "Years of experience must be >= 0")
    @Max(value = 100, message = "Years of experience must be <= 100")
    private Integer yearsOfExperience;
    
    @Size(max = 5000, message = "Bio must not exceed 5000 characters")
    private String bio;
    
    @Size(max = 255, message = "Certification must not exceed 255 characters")
    private String certification;
    
    private LocalDate hireDate;
    
    // Constructors
    public Instructor() {}
    
    public Instructor(Integer userId, String specialization, Integer yearsOfExperience,
                     String bio, String certification, LocalDate hireDate) {
        this.userId = userId;
        this.specialization = specialization;
        this.yearsOfExperience = yearsOfExperience;
        this.bio = bio;
        this.certification = certification;
        this.hireDate = hireDate;
    }
    
    // Getters and Setters
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    
    public Integer getYearsOfExperience() { return yearsOfExperience; }
    public void setYearsOfExperience(Integer yearsOfExperience) { this.yearsOfExperience = yearsOfExperience; }
    
    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }
    
    public String getCertification() { return certification; }
    public void setCertification(String certification) { this.certification = certification; }
    
    public LocalDate getHireDate() { return hireDate; }
    public void setHireDate(LocalDate hireDate) { this.hireDate = hireDate; }
}






