-- PSM E-Learning schema (MySQL)
-- Safe to import multiple times (uses IF NOT EXISTS and adds indexes conditionally)

-- Database
CREATE DATABASE IF NOT EXISTS `psm_elearning` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `psm_elearning`;

-- Users (base identity)
CREATE TABLE IF NOT EXISTS `User` (
  `UserID` INT AUTO_INCREMENT PRIMARY KEY,
  `FullName` VARCHAR(100) NOT NULL,
  `Email` VARCHAR(150) NOT NULL,
  `PasswordHash` VARCHAR(255) NOT NULL,
  `Phone` VARCHAR(30) NOT NULL,
  `Role` ENUM('Student','Instructor','Admin') NOT NULL,
  `Status` ENUM('Active','Suspended','Pending') NOT NULL DEFAULT 'Active',
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LastLogin` DATETIME NULL,
  UNIQUE KEY `uk_user_email` (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Students (1:1 with User)
CREATE TABLE IF NOT EXISTS `Student` (
  `UserID` INT NOT NULL,
  `RegNumber` VARCHAR(20) NULL,
  `Qualification` VARCHAR(100) NULL,
  `Country` VARCHAR(100) NOT NULL,
  `State` VARCHAR(100) NULL,
  `PassportPath` VARCHAR(255) NULL,
  `DOB` DATE NULL,
  `Gender` VARCHAR(10) NULL,
  `EmergencyContact` VARCHAR(20) NULL,
  `RegistrationDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_student_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Unique index for Student.RegNumber (added separately to allow conditional create)
ALTER TABLE `Student` ADD UNIQUE KEY `uk_student_regnumber` (`RegNumber`);

-- Instructors (1:1 with User)
CREATE TABLE IF NOT EXISTS `Instructor` (
  `UserID` INT NOT NULL,
  `Department` VARCHAR(100) NULL,
  `Bio` TEXT NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_instructor_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Admins (1:1 with User)
CREATE TABLE IF NOT EXISTS `Admin` (
  `UserID` INT NOT NULL,
  `Title` VARCHAR(100) NULL,
  PRIMARY KEY (`UserID`),
  CONSTRAINT `fk_admin_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Courses
CREATE TABLE IF NOT EXISTS `Course` (
  `CourseID` INT AUTO_INCREMENT PRIMARY KEY,
  `Title` VARCHAR(200) NOT NULL,
  `Description` TEXT NULL,
  `InstructorID` INT NOT NULL,
  `Price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_course_instructor` (`InstructorID`),
  CONSTRAINT `fk_course_instructor` FOREIGN KEY (`InstructorID`) REFERENCES `Instructor`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Materials
CREATE TABLE IF NOT EXISTS `Material` (
  `MaterialID` INT AUTO_INCREMENT PRIMARY KEY,
  `CourseID` INT NOT NULL,
  `Title` VARCHAR(200) NOT NULL,
  `FilePath` VARCHAR(255) NULL,
  `Type` VARCHAR(50) NULL,
  `UploadedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_material_course` (`CourseID`),
  CONSTRAINT `fk_material_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Enrollments
CREATE TABLE IF NOT EXISTS `Enrollment` (
  `EnrollmentID` INT AUTO_INCREMENT PRIMARY KEY,
  `StudentID` INT NOT NULL,
  `CourseID` INT NOT NULL,
  `Status` ENUM('Pending','Active','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `PaymentStatus` ENUM('Pending','Paid','Failed') NOT NULL DEFAULT 'Pending',
  `PaymentRef` VARCHAR(100) NULL,
  `EnrolledAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CompletionStatus` ENUM('Not Started','In Progress','Completed') NOT NULL DEFAULT 'Not Started',
  UNIQUE KEY `uk_enrollment_student_course` (`StudentID`, `CourseID`),
  KEY `idx_enrollment_course` (`CourseID`),
  KEY `idx_enrollment_payment_status` (`PaymentStatus`),
  CONSTRAINT `fk_enrollment_student` FOREIGN KEY (`StudentID`) REFERENCES `Student`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payments (Paystack Integration)
CREATE TABLE IF NOT EXISTS `Payment` (
  `PaymentID` INT AUTO_INCREMENT PRIMARY KEY,
  `EnrollmentID` INT NOT NULL,
  `Amount` DECIMAL(10,2) NOT NULL,
  `Method` VARCHAR(50) NULL,
  `Status` ENUM('Pending','Paid','Failed','Refunded','Abandoned') NOT NULL DEFAULT 'Pending',
  `PaidAt` DATETIME NULL,
  `PaymentRef` VARCHAR(100) NULL,
  `PaystackReference` VARCHAR(255) NULL,
  `AccessCode` VARCHAR(255) NULL,
  `AuthorizationUrl` TEXT NULL,
  `PaystackStatus` VARCHAR(50) NULL,
  UNIQUE KEY `uk_payment_ref` (`PaymentRef`),
  UNIQUE KEY `uk_paystack_ref` (`PaystackReference`),
  KEY `idx_payment_enrollment` (`EnrollmentID`),
  CONSTRAINT `fk_payment_enrollment` FOREIGN KEY (`EnrollmentID`) REFERENCES `Enrollment`(`EnrollmentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessments
CREATE TABLE IF NOT EXISTS `Assessment` (
  `AssessmentID` INT AUTO_INCREMENT PRIMARY KEY,
  `CourseID` INT NOT NULL,
  `Title` VARCHAR(200) NOT NULL,
  `Description` TEXT NULL,
  `DueDate` DATETIME NULL,
  KEY `idx_assessment_course` (`CourseID`),
  CONSTRAINT `fk_assessment_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment Questions
CREATE TABLE IF NOT EXISTS `AssessmentQuestion` (
  `QuestionID` INT AUTO_INCREMENT PRIMARY KEY,
  `AssessmentID` INT NOT NULL,
  `QuestionText` TEXT NOT NULL,
  `CorrectAnswer` VARCHAR(200) NULL,
  KEY `idx_question_assessment` (`AssessmentID`),
  CONSTRAINT `fk_question_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assessment Submissions
CREATE TABLE IF NOT EXISTS `AssessmentSubmission` (
  `SubmissionID` INT AUTO_INCREMENT PRIMARY KEY,
  `AssessmentID` INT NOT NULL,
  `StudentID` INT NOT NULL,
  `Answer` TEXT NULL,
  `Score` DECIMAL(5,2) NULL,
  `SubmittedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_submission_assessment` (`AssessmentID`),
  KEY `idx_submission_student` (`StudentID`),
  CONSTRAINT `fk_submission_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_submission_student` FOREIGN KEY (`StudentID`) REFERENCES `Student`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Certificates
CREATE TABLE IF NOT EXISTS `Certificate` (
  `CertificateID` INT AUTO_INCREMENT PRIMARY KEY,
  `StudentID` INT NOT NULL,
  `CourseID` INT NOT NULL,
  `CertificateCode` VARCHAR(50) NOT NULL,
  `IssuedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_certificate_code` (`CertificateCode`),
  UNIQUE KEY `uk_certificate_student_course` (`StudentID`, `CourseID`),
  KEY `idx_certificate_course` (`CourseID`),
  CONSTRAINT `fk_certificate_student` FOREIGN KEY (`StudentID`) REFERENCES `Student`(`UserID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_certificate_course` FOREIGN KEY (`CourseID`) REFERENCES `Course`(`CourseID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
