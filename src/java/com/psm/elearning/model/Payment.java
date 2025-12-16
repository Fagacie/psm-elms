package com.psm.elearning.model;

import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

/**
 * Payment entity representing payment transactions for course enrollments.
 * Integrated with Paystack payment gateway.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class Payment {
    @NotNull(message = "Payment ID cannot be null")
    private Integer paymentId;
    
    @NotNull(message = "Enrollment ID is required")
    private Integer enrollmentId;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Amount must be greater than 0")
    @DecimalMax(value = "999999.99", message = "Amount must not exceed 999999.99")
    private Double amount;
    
    @Size(max = 50, message = "Payment method must not exceed 50 characters")
    private String method; // Paystack payment channel: card, bank, ussd, qr, mobile_money, bank_transfer
    
    @NotBlank(message = "Payment status is required")
    @Pattern(regexp = "^(Pending|Success|Failed|Abandoned)$", message = "Status must be Pending, Success, Failed, or Abandoned")
    private String status;
    
    private LocalDateTime paymentDate;
    
    @Size(max = 100, message = "Payment reference must not exceed 100 characters")
    private String paymentRef; // Our internal reference (PAY-timestamp-UUID)
    
    // Paystack-specific fields
    @Size(max = 100, message = "Paystack reference must not exceed 100 characters")
    private String paystackReference; // Paystack transaction reference
    
    @Size(max = 100, message = "Access code must not exceed 100 characters")
    private String accessCode; // Paystack access code for transaction
    
    @Size(max = 500, message = "Authorization URL must not exceed 500 characters")
    private String authorizationUrl; // Paystack authorization URL to redirect user
    
    @Size(max = 50, message = "Paystack status must not exceed 50 characters")
    private String paystackStatus; // Paystack transaction status (success, failed, abandoned)
    
    // Additional fields for joined queries
    @Size(max = 200, message = "Course name must not exceed 200 characters")
    private String courseName;
    
    @Size(max = 200, message = "Student name must not exceed 200 characters")
    private String studentName;
    
    @Size(max = 150, message = "Student email must not exceed 150 characters")
    private String studentEmail;

    // Constructors for different use cases
    public Payment(Integer enrollmentId, Double amount, String method, String status) {
        this.enrollmentId = enrollmentId;
        this.amount = amount;
        this.method = method;
        this.status = status;
    }
    
    // Constructor for Paystack initialization
    public Payment(Integer enrollmentId, Double amount, String paystackReference, 
                   String accessCode, String authorizationUrl) {
        this.enrollmentId = enrollmentId;
        this.amount = amount;
        this.paystackReference = paystackReference;
        this.accessCode = accessCode;
        this.authorizationUrl = authorizationUrl;
        this.status = "Pending";
        this.paystackStatus = "pending";
    }
    
    public Payment(Integer paymentId, Integer enrollmentId, Double amount, String method, 
                  String status, LocalDateTime paymentDate, String paymentRef) {
        this.paymentId = paymentId;
        this.enrollmentId = enrollmentId;
        this.amount = amount;
        this.method = method;
        this.status = status;
        this.paymentDate = paymentDate;
        this.paymentRef = paymentRef;
    }
    
    // Default constructor
    public Payment() {}
    
    // Getters and Setters
    public Integer getPaymentId() { return paymentId; }
    public void setPaymentId(Integer paymentId) { this.paymentId = paymentId; }
    
    public Integer getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(Integer enrollmentId) { this.enrollmentId = enrollmentId; }
    
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }
    
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }
    
    public String getPaymentRef() { return paymentRef; }
    public void setPaymentRef(String paymentRef) { this.paymentRef = paymentRef; }
    
    public String getPaystackReference() { return paystackReference; }
    public void setPaystackReference(String paystackReference) { this.paystackReference = paystackReference; }
    
    public String getAccessCode() { return accessCode; }
    public void setAccessCode(String accessCode) { this.accessCode = accessCode; }
    
    public String getAuthorizationUrl() { return authorizationUrl; }
    public void setAuthorizationUrl(String authorizationUrl) { this.authorizationUrl = authorizationUrl; }
    
    public String getPaystackStatus() { return paystackStatus; }
    public void setPaystackStatus(String paystackStatus) { this.paystackStatus = paystackStatus; }
    
    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
}






