package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * Enrollment entity representing a student's enrollment in a course with payment tracking.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Enrollment {
    @NotNull(message = "Enrollment ID cannot be null")
    private Integer enrollmentId;
    
    @NotNull(message = "User ID is required")
    private Integer userId;
    
    @NotNull(message = "Course ID is required")
    private Integer courseId;
    
    @NotBlank(message = "Enrollment status is required")
    @Pattern(regexp = "^(Pending|Enrolled|Cancelled|Active|Completed)$", 
             message = "Status must be Pending, Enrolled, Cancelled, Active, or Completed")
    private String status;
    
    @NotBlank(message = "Payment status is required")
    @Pattern(regexp = "^(Pending|Paid|Failed)$", 
             message = "Payment status must be Pending, Paid, or Failed")
    private String paymentStatus;
    
    @Size(max = 100, message = "Payment reference must not exceed 100 characters")
    private String paymentRef;
    
    private LocalDateTime enrollmentDate;
    private LocalDateTime updatedDate;
    
    @Pattern(regexp = "^(Not Started|In Progress|Completed)$", 
             message = "Completion status must be Not Started, In Progress, or Completed")
    private String completionStatus;

    private Integer progress;
    
    // Additional fields for joined queries
    @Size(max = 200, message = "Course name must not exceed 200 characters")
    private String courseName;
    
    @Size(max = 5000, message = "Course description must not exceed 5000 characters")
    private String courseDescription;
    
    @Size(max = 200, message = "Student name must not exceed 200 characters")
    private String studentName;
    
    @Email(message = "Student email should be valid")
    @Size(max = 150, message = "Student email must not exceed 150 characters")
    private String studentEmail;
    
    @DecimalMin(value = "0.0", message = "Course price must be >= 0")
    @DecimalMax(value = "999999.99", message = "Course price must not exceed 999999.99")
    private Double coursePrice;
    
    @Size(max = 200, message = "Instructor name must not exceed 200 characters")
    private String instructorName;

    @Email(message = "Instructor email should be valid")
    @Size(max = 150, message = "Instructor email must not exceed 150 characters")
    private String instructorEmail;
    
    // Status constants
    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_ENROLLED = "Enrolled";
    public static final String STATUS_CANCELLED = "Cancelled";
    public static final String STATUS_ACTIVE = "Active";
    public static final String STATUS_COMPLETED = "Completed";
    
    public static final String PAYMENT_STATUS_PENDING = "Pending";
    public static final String PAYMENT_STATUS_PAID = "Paid";
    public static final String PAYMENT_STATUS_FAILED = "Failed";
    
    public static final String COMPLETION_NOT_STARTED = "Not Started";
    public static final String COMPLETION_IN_PROGRESS = "In Progress";
    public static final String COMPLETION_COMPLETED = "Completed";

    // Constructors for different use cases
    public Enrollment(Integer userId, Integer courseId, String status, String paymentStatus) {
        this.userId = userId;
        this.courseId = courseId;
        this.status = status;
        this.paymentStatus = paymentStatus;
    }
    
    public Enrollment(Integer enrollmentId, Integer userId, Integer courseId, String status, 
                     String paymentStatus, String paymentRef, LocalDateTime enrollmentDate, 
                     LocalDateTime updatedDate, String completionStatus) {
        this.enrollmentId = enrollmentId;
        this.userId = userId;
        this.courseId = courseId;
        this.status = status;
        this.paymentStatus = paymentStatus;
        this.paymentRef = paymentRef;
        this.enrollmentDate = enrollmentDate;
        this.updatedDate = updatedDate;
        this.completionStatus = completionStatus;
    }
    
    // Default constructor
    public Enrollment() {}
    
    // Getters and Setters
    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }
    
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    
    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public String getPaymentRef() { return paymentRef; }
    public void setPaymentRef(String paymentRef) { this.paymentRef = paymentRef; }
    
    public LocalDateTime getEnrollmentDate() { return enrollmentDate; }
    public void setEnrollmentDate(LocalDateTime enrollmentDate) { this.enrollmentDate = enrollmentDate; }
    
    public LocalDateTime getUpdatedDate() { return updatedDate; }
    public void setUpdatedDate(LocalDateTime updatedDate) { this.updatedDate = updatedDate; }
    
    public String getCompletionStatus() { return completionStatus; }
    public void setCompletionStatus(String completionStatus) { this.completionStatus = completionStatus; }

    public Integer getProgress() { return progress; }
    public void setProgress(Integer progress) { this.progress = progress; }
    
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    
    public String getCourseDescription() { return courseDescription; }
    public void setCourseDescription(String courseDescription) { this.courseDescription = courseDescription; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    
    public Double getCoursePrice() { return coursePrice; }
    public void setCoursePrice(Double coursePrice) { this.coursePrice = coursePrice; }
    
    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getInstructorEmail() { return instructorEmail; }
    public void setInstructorEmail(String instructorEmail) { this.instructorEmail = instructorEmail; }
}
