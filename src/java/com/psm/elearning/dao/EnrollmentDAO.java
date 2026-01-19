package com.psm.elearning.dao;

import com.psm.elearning.model.Enrollment;
import java.util.List;

/**
 * DAO interface for Enrollment operations.
 */
public interface EnrollmentDAO {
    
    /**
     * Create a new enrollment record (status=Pending, paymentStatus=Pending).
     * @param enrollment Enrollment object with userId, courseId
     * @return Created Enrollment with generated ID, or null if failed
     */
    Enrollment createEnrollment(Enrollment enrollment);
    
    /**
     * Check if a student is already enrolled in a course.
     * @param userId Student user ID
     * @param courseId Course ID
     * @return true if enrollment exists, false otherwise
     */
    boolean checkExistingEnrollment(Integer userId, Integer courseId);
    
    /**
     * Update payment status of an enrollment.
     * @param enrollmentId Enrollment ID
     * @param paymentStatus New payment status (Pending, Paid, Failed)
     * @param paymentRef Payment reference number
     * @return true if updated successfully, false otherwise
     */
    boolean updatePaymentStatus(Integer enrollmentId, String paymentStatus, String paymentRef);
    
    /**
     * Update enrollment status.
     * @param enrollmentId Enrollment ID
     * @param status New status (Pending, Enrolled, Cancelled)
     * @return true if updated successfully, false otherwise
     */
    boolean updateStatus(Integer enrollmentId, String status);
    
    /**
     * Get all enrollments for a specific student with course details.
     * @param userId Student user ID
     * @return List of Enrollment objects with course information
     */
    List<Enrollment> getEnrollmentsByStudent(Integer userId);
    
    /**
     * Get a specific enrollment by ID with full details.
     * @param enrollmentId Enrollment ID
     * @return Enrollment object with course details, or null if not found
     */
    Enrollment getEnrollment(Integer enrollmentId);
    
    /**
     * Get all enrollments (for admin) with student and course details.
     * @return List of all Enrollment objects
     */
    List<Enrollment> getAllEnrollments();
    
    /**
     * Get all enrollments for a specific course with student details.
     * @param courseId Course ID
     * @return List of Enrollment objects with student information
     */
    List<Enrollment> getEnrollmentsByCourse(Integer courseId);
}
