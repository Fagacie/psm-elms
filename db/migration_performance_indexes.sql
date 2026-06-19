-- Performance indexes for common dashboard and activity queries (idempotent via SchemaSqlRunner error handling)

CREATE INDEX idx_notification_recipient_read ON Notification (RecipientUserID, IsRead);
CREATE INDEX idx_material_progress_user_viewed ON MaterialProgress (UserID, ViewedAt);
CREATE INDEX idx_submission_user_submit_date ON AssessmentSubmission (UserID, SubmitDate);
CREATE INDEX idx_user_role ON User (Role);
CREATE INDEX idx_user_created_at ON User (CreatedAt);
CREATE INDEX idx_enrollment_enrollment_date ON Enrollment (EnrollmentDate);
CREATE INDEX idx_course_instructor_status ON Course (InstructorID, Status);
CREATE INDEX idx_material_course ON Material (CourseID);
CREATE INDEX idx_assessment_course ON Assessment (CourseID);
CREATE INDEX idx_submission_assessment ON AssessmentSubmission (AssessmentID);

-- Dashboard Reporting Indexes
CREATE INDEX idx_payment_status_date ON Payment (PaymentStatus, PaymentDate);
CREATE INDEX idx_payment_paystack_ref ON Payment (PaystackReference);
CREATE INDEX idx_enrollment_course_status_date ON Enrollment (CourseID, Status, EnrollmentDate);
CREATE INDEX idx_enrollment_user_completion ON Enrollment (UserID, CompletionStatus);
