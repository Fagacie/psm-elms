package com.psm.elearning.model;

import jakarta.validation.constraints.*;

/**
 * Admin entity representing administrator-specific attributes.
 * Matches the Admin table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Admin {
    @NotNull(message = "User ID cannot be null")
    private Integer userId;
    
    @Size(max = 100, message = "Position must not exceed 100 characters")
    private String position;
    
    @Size(max = 50, message = "Permission level must not exceed 50 characters")
    private String permissionLevel;
    
    @Size(max = 100, message = "Assigned department must not exceed 100 characters")
    private String assignedDepartment;
    
    // Constructors
    public Admin() {}
    
    public Admin(Integer userId, String position, String permissionLevel, String assignedDepartment) {
        this.userId = userId;
        this.position = position;
        this.permissionLevel = permissionLevel;
        this.assignedDepartment = assignedDepartment;
    }
    
    // Getters and Setters
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    
    public String getPermissionLevel() { return permissionLevel; }
    public void setPermissionLevel(String permissionLevel) { this.permissionLevel = permissionLevel; }
    
    public String getAssignedDepartment() { return assignedDepartment; }
    public void setAssignedDepartment(String assignedDepartment) { this.assignedDepartment = assignedDepartment; }
}






