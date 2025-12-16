package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Student entity extending user-specific attributes.
 * Matches the Student table schema.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Student {
    
    // Default constructor
    public Student() {}
    
    // Constructor with all fields
    public Student(Integer userId, String regNumber, String qualification, String program,
                   String country, String state, String passportPath, LocalDate dob,
                   String gender, String emergencyContact, Integer enrollmentYear,
                   Integer currentSemester, LocalDateTime registrationDate) {
        this.userId = userId;
        this.regNumber = regNumber;
        this.qualification = qualification;
        this.program = program;
        this.country = country;
        this.state = state;
        this.passportPath = passportPath;
        this.dob = dob;
        this.gender = gender;
        this.emergencyContact = emergencyContact;
        this.enrollmentYear = enrollmentYear;
        this.currentSemester = currentSemester;
        this.registrationDate = registrationDate;
    }
    @NotNull(message = "User ID cannot be null")
    private Integer userId;
    
    @NotBlank(message = "Registration number is required")
    @Size(max = 20, message = "Registration number must not exceed 20 characters")
    private String regNumber;
    
    @Size(max = 100, message = "Qualification must not exceed 100 characters")
    private String qualification;
    
    @Size(max = 100, message = "Program must not exceed 100 characters")
    private String program;
    
    @Size(max = 100, message = "Country must not exceed 100 characters")
    private String country;
    
    @Size(max = 100, message = "State must not exceed 100 characters")
    private String state;
    
    @Size(max = 255, message = "Passport path must not exceed 255 characters")
    private String passportPath;
    
    private LocalDate dob;
    
    @Size(max = 10, message = "Gender must not exceed 10 characters")
    private String gender;
    
    @Size(max = 50, message = "Emergency contact must not exceed 50 characters")
    private String emergencyContact;
    
    @Min(value = 2000, message = "Enrollment year must be >= 2000")
    @Max(value = 2100, message = "Enrollment year must be <= 2100")
    private Integer enrollmentYear;
    
    @Min(value = 1, message = "Current semester must be >= 1")
    @Max(value = 10, message = "Current semester must be <= 10")
    private Integer currentSemester;
    
    private LocalDateTime registrationDate;
    
    // Getters and Setters
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public String getRegNumber() { return regNumber; }
    public void setRegNumber(String regNumber) { this.regNumber = regNumber; }
    
    public String getQualification() { return qualification; }
    public void setQualification(String qualification) { this.qualification = qualification; }
    
    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
    
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    
    public String getPassportPath() { return passportPath; }
    public void setPassportPath(String passportPath) { this.passportPath = passportPath; }
    
    public LocalDate getDob() { return dob; }
    public void setDob(LocalDate dob) { this.dob = dob; }
    
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    
    public String getEmergencyContact() { return emergencyContact; }
    public void setEmergencyContact(String emergencyContact) { this.emergencyContact = emergencyContact; }
    
    public Integer getEnrollmentYear() { return enrollmentYear; }
    public void setEnrollmentYear(Integer enrollmentYear) { this.enrollmentYear = enrollmentYear; }
    
    public Integer getCurrentSemester() { return currentSemester; }
    public void setCurrentSemester(Integer currentSemester) { this.currentSemester = currentSemester; }
    
    public LocalDateTime getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(LocalDateTime registrationDate) { this.registrationDate = registrationDate; }
}





