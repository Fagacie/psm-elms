package com.psm.elearning.dao;

import com.psm.elearning.model.Enrollment;
import java.time.LocalDateTime;
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
     * Get the latest enrollment record for a student-course pair.
     * @param userId Student user ID
     * @param courseId Course ID
     * @return Latest enrollment or null if none exists
     */
    Enrollment findLatestEnrollmentByUserAndCourse(Integer userId, Integer courseId);
    
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
     * Update computed learning progress and completion state.
     * @param enrollmentId Enrollment ID
     * @param progress Progress percentage 0-100
     * @param completionStatus Completion status (Not Started, In Progress, Completed)
     * @param status Enrollment status (Pending, Enrolled, Active, Completed, Cancelled)
     * @return true if updated successfully, false otherwise
     */
    boolean updateLearningProgress(Integer enrollmentId, Integer progress, String completionStatus, String status);
    
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

    /**
     * Get all enrollments across every course owned by an instructor.
     * @param instructorId Instructor user ID
     * @return List of enrollments with student and course fee details
     */
    List<Enrollment> getEnrollmentsByInstructor(Integer instructorId);

    /**
     * Get the most recent enrollments with student and course details.
     * @param limit Maximum rows to return
     * @return Recent enrollments ordered by enrollment date descending
     */
    List<Enrollment> getRecentEnrollments(int limit);

    /**
     * Aggregate enrollment payment metrics for the admin dashboard.
     */
    EnrollmentPaymentSummary getEnrollmentPaymentSummary();

    /**
     * Daily enrollment counts and paid revenue for a date range (inclusive start, inclusive end).
     */
    List<DailyEnrollmentMetric> getDailyEnrollmentMetrics(java.time.LocalDate startDate, java.time.LocalDate endDate);
    
    /**
     * Count total students enrolled in any course created by an instructor.
     * @param instructorId Instructor user ID
     * @return Total count of unique students enrolled in instructor's courses
     */
    Integer countStudentsByInstructor(Integer instructorId);
    
    /**
     * Count total enrollments (not just unique students) for instructor's courses.
     * @param instructorId Instructor user ID
     * @return Total count of enrollments in instructor's courses
     */
    Integer countEnrollmentsByInstructor(Integer instructorId);
    
    /**
     * Count pending enrollments for instructor's courses.
     * @param instructorId Instructor user ID
     * @return Count of enrollments with status=Pending
     */
    Integer countPendingEnrollmentsByInstructor(Integer instructorId);
    
    /**
     * Count active (Enrolled status) enrollments for instructor's courses.
     * @param instructorId Instructor user ID
     * @return Count of enrollments with status=Enrolled
     */
    Integer countActiveEnrollmentsByInstructor(Integer instructorId);

    /**
     * Update whether the remaining course duration reminder has been sent to the student.
     * @param enrollmentId Enrollment ID
     * @param reminderSent True if reminder email has been sent
     * @return true if updated successfully, false otherwise
     */
    boolean updateReminderSent(Integer enrollmentId, boolean reminderSent);

    /**
     * Update the explicit expiry date override for an enrollment.
     * @param enrollmentId Enrollment ID
     * @param expiryDateOverride Nullable explicit access end date
     * @return true if updated successfully, false otherwise
     */
    boolean updateExpiryDateOverride(Integer enrollmentId, LocalDateTime expiryDateOverride);

    /**
     * Aggregate payment counts and revenue for admin dashboards.
     */
    class EnrollmentPaymentSummary {
        private final int totalEnrollments;
        private final int paidEnrollments;
        private final int pendingEnrollments;
        private final int cancelledEnrollments;
        private final double totalRevenue;

        public EnrollmentPaymentSummary(int totalEnrollments, int paidEnrollments, int pendingEnrollments,
                                        int cancelledEnrollments, double totalRevenue) {
            this.totalEnrollments = totalEnrollments;
            this.paidEnrollments = paidEnrollments;
            this.pendingEnrollments = pendingEnrollments;
            this.cancelledEnrollments = cancelledEnrollments;
            this.totalRevenue = totalRevenue;
        }

        public int getTotalEnrollments() { return totalEnrollments; }
        public int getPaidEnrollments() { return paidEnrollments; }
        public int getPendingEnrollments() { return pendingEnrollments; }
        public int getCancelledEnrollments() { return cancelledEnrollments; }
        public double getTotalRevenue() { return totalRevenue; }
    }

    /**
     * Per-day enrollment activity for dashboard charts.
     */
    class DailyEnrollmentMetric {
        private final java.time.LocalDate date;
        private final int enrollmentCount;
        private final double revenue;

        public DailyEnrollmentMetric(java.time.LocalDate date, int enrollmentCount, double revenue) {
            this.date = date;
            this.enrollmentCount = enrollmentCount;
            this.revenue = revenue;
        }

        public java.time.LocalDate getDate() { return date; }
        public int getEnrollmentCount() { return enrollmentCount; }
        public double getRevenue() { return revenue; }
    }

    /**
     * Statistics for instructor dashboard.
     */
    class InstructorStats {
        private final int studentCount;
        private final int enrollmentCount;
        private final int pendingCount;
        private final int activeCount;

        public InstructorStats(int studentCount, int enrollmentCount, int pendingCount, int activeCount) {
            this.studentCount = studentCount;
            this.enrollmentCount = enrollmentCount;
            this.pendingCount = pendingCount;
            this.activeCount = activeCount;
        }

        public int getStudentCount() { return studentCount; }
        public int getEnrollmentCount() { return enrollmentCount; }
        public int getPendingCount() { return pendingCount; }
        public int getActiveCount() { return activeCount; }
    }

    /**
     * Fetch aggregate statistics for an instructor.
     */
    InstructorStats getInstructorStats(Integer instructorId);

    /**
     * Get student enrollment counts grouped by course IDs.
     */
    java.util.Map<Integer, Integer> getEnrollmentCountsByCourseIds(List<Integer> courseIds);
}


