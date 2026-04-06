-- PSM E-Learning schema (MySQL)
-- Aligned to current Java code (DAOs + models)

CREATE DATABASE IF NOT EXISTS `psm_elearning` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `psm_elearning`;

-- Users
CREATE TABLE IF NOT EXISTS `User` (
  `UserID` INT AUTO_INCREMENT PRIMARY KEY,
  `FullName` VARCHAR(100) NOT NULL,
  `Email` VARCHAR(150) NOT NULL,
  `PasswordHash` VARCHAR(255) NOT NULL,
  `Phone` VARCHAR(30) NOT NULL,
  `Role` ENUM('Student','Instructor','Admin') NOT NULL,
  `Status` ENUM('Active','Suspended','Pending') NOT NULL DEFAULT 'Active',
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `LastLogin` DATETIME NULL,
  `ProfilePicture` VARCHAR(255) NULL,
  UNIQUE KEY `uk_user_email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Students (1:1 with User)
CREATE TABLE IF NOT EXISTS `Student` (
  `UserID` INT NOT NULL,
  `RegNumber` VARCHAR(20) NOT NULL,
  `Qualification` VARCHAR(100) NULL,
  `Country` VARCHAR(100) NOT NULL,
  `State` VARCHAR(100) NULL,
  `PassportPath` VARCHAR(255) NULL,
  `DOB` DATE NULL,
  `Gender` VARCHAR(10) NULL,
  `EmergencyContact` VARCHAR(20) NULL,
  `RegistrationDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `uk_student_regnumber` (`RegNumber`),
  CONSTRAINT `fk_student_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Instructors (1:1 with User)
CREATE TABLE IF NOT EXISTS `Instructor` (
  `UserID` INT NOT NULL,
  `Specialization` VARCHAR(150) NULL,
  `YearsOfExperience` INT NULL,
  `Bio` TEXT NULL,
  `Certification` VARCHAR(255) NULL,
  `HireDate` DATE NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_instructor_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Admins (1:1 with User)
CREATE TABLE IF NOT EXISTS `Admin` (
  `UserID` INT NOT NULL,
  `Position` VARCHAR(100) NULL,
  `PermissionLevel` VARCHAR(50) NULL,
  `AssignedDepartment` VARCHAR(100) NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_admin_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Instructor Applications
CREATE TABLE IF NOT EXISTS `InstructorApplication` (
  `ApplicationID` INT AUTO_INCREMENT PRIMARY KEY,
  `FullName` VARCHAR(100) NOT NULL,
  `Email` VARCHAR(150) NOT NULL,
  `Phone` VARCHAR(30) NOT NULL,
  `Specialization` VARCHAR(150) NOT NULL,
  `YearsOfExperience` INT NULL,
  `Qualification` VARCHAR(150) NOT NULL,
  `CoverMessage` TEXT NULL,
  `CvPath` VARCHAR(1024) NOT NULL,
  `Status` ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `ReviewedBy` INT NULL,
  `ReviewedAt` TIMESTAMP NULL DEFAULT NULL,
  `AdminNotes` TEXT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_instructor_application_email` (`Email`),
  KEY `idx_instructor_application_status` (`Status`),
  CONSTRAINT `fk_instructor_application_reviewer` FOREIGN KEY (`ReviewedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Keep existing environments aligned with current column sizes.
ALTER TABLE `InstructorApplication`
  MODIFY COLUMN `CvPath` VARCHAR(1024) NOT NULL;

-- Notifications
CREATE TABLE IF NOT EXISTS `Notification` (
  `NotificationID` INT AUTO_INCREMENT PRIMARY KEY,
  `RecipientUserID` INT NULL,
  `RecipientEmail` VARCHAR(150) NULL,
  `RecipientName` VARCHAR(100) NULL,
  `Title` VARCHAR(200) NOT NULL,
  `Message` TEXT NOT NULL,
  `NotificationType` VARCHAR(80) NOT NULL,
  `RelatedEntityType` VARCHAR(80) NULL,
  `RelatedEntityID` INT NULL,
  `Channel` VARCHAR(20) NOT NULL DEFAULT 'InApp',
  `IsRead` TINYINT(1) NOT NULL DEFAULT 0,
  `ReadAt` TIMESTAMP NULL DEFAULT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_notification_recipient_user` (`RecipientUserID`),
  KEY `idx_notification_recipient_email` (`RecipientEmail`),
  KEY `idx_notification_read` (`IsRead`),
  KEY `idx_notification_related` (`RelatedEntityType`, `RelatedEntityID`),
  CONSTRAINT `fk_notification_recipient_user` FOREIGN KEY (`RecipientUserID`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Courses
CREATE TABLE IF NOT EXISTS `Course` (
  `CourseID` INT AUTO_INCREMENT PRIMARY KEY,
  `Title` VARCHAR(200) NOT NULL,
  `Description` TEXT NULL,
  `Category` VARCHAR(100) NULL,
  `Level` VARCHAR(50) NULL,
  `InstructorID` INT NOT NULL,
  `CourseFee` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `Status` ENUM('Pending','Approved','Archived') NOT NULL DEFAULT 'Pending',
  `ApprovedBy` INT NULL,
  `CourseBanner` VARCHAR(255) NULL,
  `Duration` INT NULL,
  `Language` VARCHAR(50) DEFAULT 'English',
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ApprovedAt` DATETIME NULL,
  KEY `idx_course_instructor` (`InstructorID`),
  KEY `idx_course_status` (`Status`),
  CONSTRAINT `fk_course_instructor` FOREIGN KEY (`InstructorID`) REFERENCES `Instructor`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Materials
CREATE TABLE IF NOT EXISTS `Material` (
  `MaterialID` INT AUTO_INCREMENT PRIMARY KEY,
  `CourseID` INT NOT NULL,
  `Title` VARCHAR(200) NOT NULL,
  `Description` TEXT NULL,
  `MaterialType` VARCHAR(50) NULL,
  `FilePath` VARCHAR(255) NULL,
  `UploadedBy` INT NULL,
  `UploadDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `VersionNumber` VARCHAR(50) NULL,
  `DisplayOrder` INT NULL,
  `IsDeleted` TINYINT(1) NOT NULL DEFAULT 0,
  `DeletedAt` TIMESTAMP NULL DEFAULT NULL,
  `DeletedBy` INT NULL,
  KEY `idx_material_course` (`CourseID`),
  KEY `idx_material_course_order` (`CourseID`, `DisplayOrder`),
  KEY `idx_material_deleted` (`IsDeleted`),
  CONSTRAINT `fk_material_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_material_uploader` FOREIGN KEY (`UploadedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_material_deleted_by` FOREIGN KEY (`DeletedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Material Progress
CREATE TABLE IF NOT EXISTS `MaterialProgress` (
  `ProgressID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `MaterialID` INT NOT NULL,
  `ViewedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_material_progress` (`UserID`, `MaterialID`),
  KEY `idx_material_progress_user` (`UserID`),
  KEY `idx_material_progress_material` (`MaterialID`),
  CONSTRAINT `fk_material_progress_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_material_progress_material` FOREIGN KEY (`MaterialID`) REFERENCES `Material`(`MaterialID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Enrollments
CREATE TABLE IF NOT EXISTS `Enrollment` (
  `EnrollmentID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `CourseID` INT NOT NULL,
  `Status` ENUM('Pending','Enrolled','Active','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `PaymentStatus` ENUM('Pending','Paid','Failed') NOT NULL DEFAULT 'Pending',
  `PaymentRef` VARCHAR(100) NULL,
  `EnrollmentDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CompletionStatus` ENUM('Not Started','In Progress','Completed') NOT NULL DEFAULT 'Not Started',
  `Progress` INT DEFAULT 0,
  UNIQUE KEY `uk_enrollment_user_course` (`UserID`, `CourseID`),
  KEY `idx_enrollment_course` (`CourseID`),
  KEY `idx_enrollment_user` (`UserID`),
  KEY `idx_enrollment_payment_status` (`PaymentStatus`),
  KEY `idx_enrollment_status` (`Status`),
  CONSTRAINT `fk_enrollment_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payments (Paystack Integration)
CREATE TABLE IF NOT EXISTS `Payment` (
  `PaymentID` INT AUTO_INCREMENT PRIMARY KEY,
  `EnrollmentID` INT NOT NULL,
  `Amount` DECIMAL(10,2) NOT NULL,
  `PaymentMethod` VARCHAR(50) NULL,
  `PaymentStatus` ENUM('Pending','Paid','Failed','Abandoned') NOT NULL DEFAULT 'Pending',
  `PaymentDate` DATETIME NULL,
  `Reference` VARCHAR(100) NULL,
  `PaymentRef` VARCHAR(100) NULL,
  `PaystackReference` VARCHAR(255) NULL,
  `AccessCode` VARCHAR(255) NULL,
  `AuthorizationUrl` TEXT NULL,
  `PaystackStatus` VARCHAR(50) NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_payment_ref` (`PaymentRef`),
  UNIQUE KEY `uk_payment_reference` (`Reference`),
  KEY `idx_payment_enrollment` (`EnrollmentID`),
  KEY `idx_payment_status` (`PaymentStatus`),
  CONSTRAINT `fk_payment_enrollment` FOREIGN KEY (`EnrollmentID`) REFERENCES `Enrollment`(`EnrollmentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessments
CREATE TABLE IF NOT EXISTS `Assessment` (
  `AssessmentID` INT AUTO_INCREMENT PRIMARY KEY,
  `CourseID` INT NOT NULL,
  `Title` VARCHAR(200) NOT NULL,
  `Type` VARCHAR(50) NULL,
  `Duration` INT NULL,
  `TotalMarks` INT NULL,
  `Instructions` TEXT NULL,
  `MaxAttempts` INT NOT NULL DEFAULT 1,
  `QuestionsPerPage` INT NOT NULL DEFAULT 2,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `CreatedBy` INT NOT NULL,
  KEY `idx_assessment_course` (`CourseID`),
  CONSTRAINT `fk_assessment_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_assessment_creator` FOREIGN KEY (`CreatedBy`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment Questions
CREATE TABLE IF NOT EXISTS `AssessmentQuestion` (
  `QuestionID` INT AUTO_INCREMENT PRIMARY KEY,
  `AssessmentID` INT NOT NULL,
  `QuestionText` TEXT NOT NULL,
  `OptionA` VARCHAR(500) NULL,
  `OptionB` VARCHAR(500) NULL,
  `OptionC` VARCHAR(500) NULL,
  `OptionD` VARCHAR(500) NULL,
  `CorrectOption` VARCHAR(10) NULL,
  `Marks` DECIMAL(5,2) NULL,
  KEY `idx_question_assessment` (`AssessmentID`),
  CONSTRAINT `fk_question_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment Submissions
CREATE TABLE IF NOT EXISTS `AssessmentSubmission` (
  `SubmissionID` INT AUTO_INCREMENT PRIMARY KEY,
  `AssessmentID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `AnswersFilePath` VARCHAR(255) NULL,
  `Score` DECIMAL(5,2) NULL,
  `Feedback` TEXT NULL,
  `AttemptNumber` INT NOT NULL DEFAULT 1,
  `Status` ENUM('Submitted','TimedOut','AutoSubmitted') NOT NULL DEFAULT 'Submitted',
  `StartedAt` DATETIME NULL,
  `EndedAt` DATETIME NULL,
  `SubmitDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_submission_assessment` (`AssessmentID`),
  KEY `idx_submission_user` (`UserID`),
  CONSTRAINT `fk_submission_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_submission_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment Retake Requests
CREATE TABLE IF NOT EXISTS `AssessmentRetakeRequest` (
  `RequestID` INT AUTO_INCREMENT PRIMARY KEY,
  `AssessmentID` INT NOT NULL,
  `UserID` INT NOT NULL,
  `Reason` TEXT NULL,
  `Status` ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `RequestedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ReviewedAt` TIMESTAMP NULL DEFAULT NULL,
  `ReviewedBy` INT NULL,
  KEY `idx_retake_assessment` (`AssessmentID`),
  KEY `idx_retake_user` (`UserID`),
  KEY `idx_retake_status` (`Status`),
  CONSTRAINT `fk_retake_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_retake_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_retake_reviewer` FOREIGN KEY (`ReviewedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Certificates
CREATE TABLE IF NOT EXISTS `Certificate` (
  `CertificateID` INT AUTO_INCREMENT PRIMARY KEY,
  `EnrollmentID` INT NOT NULL,
  `CertificateNo` VARCHAR(50) NOT NULL,
  `IssueDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `QRCodePath` VARCHAR(255) NULL,
  `GeneratedBy` VARCHAR(100) NULL,
  `VerificationURL` VARCHAR(255) NULL,
  `Status` ENUM('Active','Revoked') NOT NULL DEFAULT 'Active',
  `RevokedAt` TIMESTAMP NULL DEFAULT NULL,
  `RevokedBy` INT NULL,
  UNIQUE KEY `uk_certificate_no` (`CertificateNo`),
  UNIQUE KEY `uk_certificate_enrollment` (`EnrollmentID`),
  KEY `idx_certificate_status` (`Status`),
  CONSTRAINT `fk_certificate_enrollment` FOREIGN KEY (`EnrollmentID`) REFERENCES `Enrollment`(`EnrollmentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Report Exports (stores generated report metadata)
CREATE TABLE IF NOT EXISTS `ReportExport` (
  `ExportID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `RoleName` VARCHAR(50) NOT NULL,
  `ReportType` VARCHAR(100) NOT NULL,
  `FiltersJson` LONGTEXT NULL,
  `ExportFormat` VARCHAR(20) NULL,
  `FilePath` VARCHAR(255) NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_report_export_user` (`UserID`),
  KEY `idx_report_export_type` (`ReportType`),
  CONSTRAINT `fk_report_export_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Report Access Log (audit trail for report module usage)
CREATE TABLE IF NOT EXISTS `ReportAccessLog` (
  `LogID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `RoleName` VARCHAR(50) NOT NULL,
  `ReportType` VARCHAR(100) NOT NULL,
  `FiltersJson` LONGTEXT NULL,
  `AccessStatus` VARCHAR(20) NOT NULL,
  `IPAddress` VARCHAR(64) NULL,
  `AccessedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_report_log_user` (`UserID`),
  KEY `idx_report_log_type` (`ReportType`),
  KEY `idx_report_log_status` (`AccessStatus`),
  CONSTRAINT `fk_report_log_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Password Reset Tokens
CREATE TABLE IF NOT EXISTS `PasswordResetToken` (
  `TokenID` INT AUTO_INCREMENT PRIMARY KEY,
  `UserID` INT NOT NULL,
  `Token` VARCHAR(255) NOT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ExpiresAt` DATETIME NOT NULL,
  `Used` BOOLEAN DEFAULT FALSE,
  UNIQUE KEY `uk_password_reset_token` (`Token`),
  KEY `idx_token_user` (`UserID`),
  CONSTRAINT `fk_token_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

