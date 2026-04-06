package com.psm.elearning.model;

import java.time.LocalDateTime;

public class CertificateView {
    private Integer certificateId;
    private Integer enrollmentId;
    private Integer courseId;
    private String certificateNo;
    private LocalDateTime issueDate;
    private String generatedBy;
    private String verificationURL;
    private String qrCodePath;
    private String status;
    private LocalDateTime revokedAt;
    private Integer revokedBy;
    private String studentName;
    private String studentEmail;
    private String regNumber;
    private String courseName;
    private String instructorName;
    private Integer studentUserId;
    private Integer courseCreatedBy;

    public Integer getCertificateId() {
        return certificateId;
    }

    public void setCertificateId(Integer certificateId) {
        this.certificateId = certificateId;
    }

    public Integer getEnrollmentId() {
        return enrollmentId;
    }

    public void setEnrollmentId(Integer enrollmentId) {
        this.enrollmentId = enrollmentId;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }

    public String getCertificateNo() {
        return certificateNo;
    }

    public void setCertificateNo(String certificateNo) {
        this.certificateNo = certificateNo;
    }

    public LocalDateTime getIssueDate() {
        return issueDate;
    }

    public void setIssueDate(LocalDateTime issueDate) {
        this.issueDate = issueDate;
    }

    public String getGeneratedBy() {
        return generatedBy;
    }

    public void setGeneratedBy(String generatedBy) {
        this.generatedBy = generatedBy;
    }

    public String getVerificationURL() {
        return verificationURL;
    }

    public void setVerificationURL(String verificationURL) {
        this.verificationURL = verificationURL;
    }

    public String getQrCodePath() {
        return qrCodePath;
    }

    public void setQrCodePath(String qrCodePath) {
        this.qrCodePath = qrCodePath;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getRevokedAt() {
        return revokedAt;
    }

    public void setRevokedAt(LocalDateTime revokedAt) {
        this.revokedAt = revokedAt;
    }

    public Integer getRevokedBy() {
        return revokedBy;
    }

    public void setRevokedBy(Integer revokedBy) {
        this.revokedBy = revokedBy;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getRegNumber() {
        return regNumber;
    }

    public void setRegNumber(String regNumber) {
        this.regNumber = regNumber;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }

    public Integer getStudentUserId() {
        return studentUserId;
    }

    public void setStudentUserId(Integer studentUserId) {
        this.studentUserId = studentUserId;
    }

    public Integer getCourseCreatedBy() {
        return courseCreatedBy;
    }

    public void setCourseCreatedBy(Integer courseCreatedBy) {
        this.courseCreatedBy = courseCreatedBy;
    }
}
