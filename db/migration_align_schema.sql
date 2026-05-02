-- Migration: Align existing database to current code-first schema
-- Target: MySQL 8.0+
-- IMPORTANT: Back up your database before running.

USE `psm_elearning`;

-- -----------------------
-- User / Student / Instructor / Admin
-- -----------------------

-- Admin: add new columns expected by code (keep old columns if present)
ALTER TABLE `Admin`
  ADD COLUMN IF NOT EXISTS `Position` VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `PermissionLevel` VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS `AssignedDepartment` VARCHAR(100) NULL;

-- Instructor: add new columns expected by code
ALTER TABLE `Instructor`
  ADD COLUMN IF NOT EXISTS `Specialization` VARCHAR(150) NULL,
  ADD COLUMN IF NOT EXISTS `YearsOfExperience` INT NULL,
  ADD COLUMN IF NOT EXISTS `Certification` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `HireDate` DATE NULL;

-- Optional: map Department -> Specialization if Department exists
UPDATE `Instructor`
   SET `Specialization` = `Department`
 WHERE `Specialization` IS NULL AND `Department` IS NOT NULL;

-- -----------------------
-- Course
-- -----------------------

-- Rename Price -> CourseFee if present (manual: comment out if already CourseFee)
-- ALTER TABLE `Course` CHANGE COLUMN `Price` `CourseFee` DECIMAL(10,2) NOT NULL DEFAULT 0.00;

ALTER TABLE `Course`
  ADD COLUMN IF NOT EXISTS `CourseFee` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- -----------------------
-- Material
-- -----------------------

ALTER TABLE `Material`
  ADD COLUMN IF NOT EXISTS `Description` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `MaterialType` VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS `UploadedBy` INT NULL,
  ADD COLUMN IF NOT EXISTS `UploadDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS `DisplayOrder` INT NULL,
  ADD COLUMN IF NOT EXISTS `IsDeleted` TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `DeletedAt` TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `DeletedBy` INT NULL;

ALTER TABLE `Material`
  DROP COLUMN IF EXISTS `VersionNumber`;

ALTER TABLE `Material`
  ADD INDEX IF NOT EXISTS `idx_material_course_order` (`CourseID`, `DisplayOrder`);

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
);

UPDATE `Material` m
JOIN (
  SELECT `MaterialID`,
         ROW_NUMBER() OVER (PARTITION BY `CourseID` ORDER BY `UploadDate` ASC, `MaterialID` ASC) AS rn
  FROM `Material`
  WHERE `IsDeleted` = 0 OR `IsDeleted` IS NULL
) x ON x.`MaterialID` = m.`MaterialID`
   SET m.`DisplayOrder` = x.rn
 WHERE m.`DisplayOrder` IS NULL;

-- Rename legacy columns if present (manual)
-- ALTER TABLE `Material` CHANGE COLUMN `Type` `MaterialType` VARCHAR(50) NULL;
-- ALTER TABLE `Material` CHANGE COLUMN `UploadedAt` `UploadDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Add FK for uploader if user table is aligned
ALTER TABLE `Material`
  ADD CONSTRAINT `fk_material_uploader` FOREIGN KEY (`UploadedBy`) REFERENCES `User`(`UserID`)
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Material`
  ADD CONSTRAINT `fk_material_deleted_by` FOREIGN KEY (`DeletedBy`) REFERENCES `User`(`UserID`)
  ON DELETE SET NULL ON UPDATE CASCADE;

-- -----------------------
-- Enrollment
-- -----------------------

-- Rename legacy columns if present (manual)
-- ALTER TABLE `Enrollment` CHANGE COLUMN `StudentID` `UserID` INT NOT NULL;
-- ALTER TABLE `Enrollment` CHANGE COLUMN `EnrolledAt` `EnrollmentDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
-- ALTER TABLE `Enrollment` CHANGE COLUMN `UpdatedAt` `UpdatedDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE `Enrollment`
  ADD COLUMN IF NOT EXISTS `UserID` INT NOT NULL,
  ADD COLUMN IF NOT EXISTS `EnrollmentDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS `UpdatedDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS `PaymentStatus` ENUM('Pending','Paid','Failed') NOT NULL DEFAULT 'Pending',
  ADD COLUMN IF NOT EXISTS `PaymentRef` VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `CompletionStatus` ENUM('Not Started','In Progress','Completed') NOT NULL DEFAULT 'Not Started',
  ADD COLUMN IF NOT EXISTS `Progress` INT DEFAULT 0;

-- Align Status enum to code
ALTER TABLE `Enrollment`
  MODIFY COLUMN `Status` ENUM('Pending','Enrolled','Active','Completed','Cancelled') NOT NULL DEFAULT 'Pending';

-- Ensure unique constraint on (UserID, CourseID)
ALTER TABLE `Enrollment`
  ADD UNIQUE KEY IF NOT EXISTS `uk_enrollment_user_course` (`UserID`, `CourseID`);

-- Switch FK to User table (drop old student FK if present)
-- ALTER TABLE `Enrollment` DROP FOREIGN KEY `fk_enrollment_student`;
ALTER TABLE `Enrollment`
  ADD CONSTRAINT `fk_enrollment_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- If you migrated StudentID -> UserID, ensure values are copied:
-- UPDATE `Enrollment` SET `UserID` = `StudentID` WHERE `UserID` IS NULL;

-- -----------------------
-- Payment
-- -----------------------

-- Rename legacy columns if present (manual)
-- ALTER TABLE `Payment` CHANGE COLUMN `Method` `PaymentMethod` VARCHAR(50) NULL;
-- ALTER TABLE `Payment` CHANGE COLUMN `Status` `PaymentStatus` ENUM('Pending','Paid','Failed','Abandoned') NOT NULL DEFAULT 'Pending';
-- ALTER TABLE `Payment` CHANGE COLUMN `PaidAt` `PaymentDate` DATETIME NULL;

ALTER TABLE `Payment`
  ADD COLUMN IF NOT EXISTS `PaymentMethod` VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS `PaymentStatus` ENUM('Pending','Paid','Failed','Abandoned') NOT NULL DEFAULT 'Pending',
  ADD COLUMN IF NOT EXISTS `PaymentDate` DATETIME NULL,
  ADD COLUMN IF NOT EXISTS `Reference` VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `PaymentRef` VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `PaystackReference` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `AccessCode` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `AuthorizationUrl` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `PaystackStatus` VARCHAR(50) NULL;

-- Populate Reference if missing
UPDATE `Payment`
   SET `Reference` = COALESCE(`Reference`, `PaystackReference`, `PaymentRef`)
 WHERE `Reference` IS NULL;


ALTER TABLE `Assessment`
  ADD COLUMN IF NOT EXISTS `Type` VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS `Duration` INT NULL,
  ADD COLUMN IF NOT EXISTS `TotalMarks` INT NULL,
  ADD COLUMN IF NOT EXISTS `Instructions` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `PlacementType` VARCHAR(20) NOT NULL DEFAULT 'final',
  ADD COLUMN IF NOT EXISTS `PlacementMaterialID` INT NULL,
  ADD COLUMN IF NOT EXISTS `MaxAttempts` INT NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS `CreatedBy` INT NOT NULL DEFAULT 0;

ALTER TABLE `Assessment`
  DROP COLUMN IF EXISTS `QuestionsPerPage`;

ALTER TABLE `Assessment`
  DROP COLUMN IF EXISTS `DueDate`;

ALTER TABLE `Assessment`
  ADD COLUMN IF NOT EXISTS `GradingMode` ENUM('auto','manual') NOT NULL DEFAULT 'auto',
  ADD COLUMN IF NOT EXISTS `SubmissionMode` ENUM('file','text','both') NOT NULL DEFAULT 'both';

UPDATE `Assessment`
SET `GradingMode` = CASE WHEN `Type` IN ('Quiz','Exam') THEN 'auto' ELSE 'manual' END
WHERE `GradingMode` IS NULL;

ALTER TABLE `Assessment`
  MODIFY COLUMN `GradingMode` ENUM('auto','manual') NOT NULL DEFAULT 'auto',
  MODIFY COLUMN `SubmissionMode` ENUM('file','text','both') NOT NULL DEFAULT 'both';

-- Optional mapping from legacy fields
UPDATE `Assessment`
   SET `TotalMarks` = COALESCE(`TotalMarks`, CAST(`MaxScore` AS SIGNED))
 WHERE `MaxScore` IS NOT NULL;
UPDATE `Assessment`
   SET `Instructions` = COALESCE(`Instructions`, `Description`)
 WHERE `Description` IS NOT NULL;

UPDATE `Assessment`
   SET `PlacementType` = CASE
         WHEN `Instructions` REGEXP '##PLACEMENT:afterMaterial:[0-9]+##' THEN 'afterMaterial'
         ELSE 'final'
       END
 WHERE `PlacementType` IS NULL OR TRIM(`PlacementType`) = '';

UPDATE `Assessment`
   SET `PlacementMaterialID` = CASE
         WHEN `Instructions` REGEXP '##PLACEMENT:afterMaterial:[0-9]+##'
           THEN CAST(
             REPLACE(
               REPLACE(
                 REGEXP_SUBSTR(`Instructions`, '##PLACEMENT:afterMaterial:[0-9]+##'),
                 '##PLACEMENT:afterMaterial:',
                 ''
               ),
               '##',
               ''
             ) AS UNSIGNED
           )
         ELSE NULL
       END
 WHERE `PlacementMaterialID` IS NULL;

UPDATE `Assessment`
   SET `Instructions` = TRIM(REPLACE(`Instructions`, REGEXP_SUBSTR(`Instructions`, '##PLACEMENT:[^#]+##'), ''))
 WHERE `Instructions` REGEXP '##PLACEMENT:[^#]+##';

ALTER TABLE `Assessment`
  ADD INDEX IF NOT EXISTS `idx_assessment_placement_material` (`PlacementMaterialID`);

ALTER TABLE `Assessment`
  ADD CONSTRAINT `fk_assessment_creator` FOREIGN KEY (`CreatedBy`) REFERENCES `User`(`UserID`)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Assessment`
  ADD CONSTRAINT `fk_assessment_placement_material` FOREIGN KEY (`PlacementMaterialID`) REFERENCES `Material`(`MaterialID`)
  ON DELETE SET NULL ON UPDATE CASCADE;

-- -----------------------
-- AssessmentQuestion
-- -----------------------

ALTER TABLE `AssessmentQuestion`
  ADD COLUMN IF NOT EXISTS `OptionA` VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS `OptionB` VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS `OptionC` VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS `OptionD` VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS `CorrectOption` VARCHAR(10) NULL,
  ADD COLUMN IF NOT EXISTS `Marks` DECIMAL(5,2) NULL;

-- Map CorrectAnswer -> CorrectOption if present
UPDATE `AssessmentQuestion`
   SET `CorrectOption` = COALESCE(`CorrectOption`, `CorrectAnswer`)
 WHERE `CorrectAnswer` IS NOT NULL;

-- -----------------------
-- AssessmentSubmission
-- -----------------------

ALTER TABLE `AssessmentSubmission`
  ADD COLUMN IF NOT EXISTS `UserID` INT NOT NULL,
  ADD COLUMN IF NOT EXISTS `AnswersFilePath` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `Feedback` TEXT NULL,
  ADD COLUMN IF NOT EXISTS `AttemptNumber` INT NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS `Status` ENUM('Submitted','TimedOut','AutoSubmitted','Graded') NOT NULL DEFAULT 'Submitted',
  ADD COLUMN IF NOT EXISTS `StartedAt` DATETIME NULL,
  ADD COLUMN IF NOT EXISTS `EndedAt` DATETIME NULL,
  ADD COLUMN IF NOT EXISTS `SubmitDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE `AssessmentSubmission`
  MODIFY COLUMN `Status` ENUM('Submitted','TimedOut','AutoSubmitted','Graded') NOT NULL DEFAULT 'Submitted';

-- Rename legacy columns if present (manual)
-- ALTER TABLE `AssessmentSubmission` CHANGE COLUMN `StudentID` `UserID` INT NOT NULL;
-- ALTER TABLE `AssessmentSubmission` CHANGE COLUMN `SubmittedAt` `SubmitDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- If you migrated StudentID -> UserID, ensure values are copied:
-- UPDATE `AssessmentSubmission` SET `UserID` = `StudentID` WHERE `UserID` IS NULL;

ALTER TABLE `AssessmentSubmission`
  ADD CONSTRAINT `fk_submission_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- -----------------------
-- Assessment Retake Request
-- -----------------------

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
  CONSTRAINT `fk_retake_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`)
  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_retake_user` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`)
  ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_retake_reviewer` FOREIGN KEY (`ReviewedBy`) REFERENCES `User`(`UserID`)
  ON DELETE SET NULL ON UPDATE CASCADE
);

-- -----------------------
-- Certificate
-- -----------------------

ALTER TABLE `Certificate`
  ADD COLUMN IF NOT EXISTS `EnrollmentID` INT NULL,
  ADD COLUMN IF NOT EXISTS `CertificateNo` VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS `IssueDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS `QRCodePath` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `GeneratedBy` VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `VerificationURL` VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS `Status` ENUM('Active','Revoked') NOT NULL DEFAULT 'Active',
  ADD COLUMN IF NOT EXISTS `RevokedAt` TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `RevokedBy` INT NULL;

ALTER TABLE `Certificate`
  ADD INDEX IF NOT EXISTS `idx_certificate_status` (`Status`);

-- Map legacy fields if present
UPDATE `Certificate`
   SET `CertificateNo` = COALESCE(`CertificateNo`, `CertificateCode`);

-- Try to populate EnrollmentID from old StudentID/CourseID pairing
UPDATE `Certificate` c
JOIN `Enrollment` e
  ON e.UserID = c.StudentID AND e.CourseID = c.CourseID
   SET c.EnrollmentID = e.EnrollmentID
 WHERE c.EnrollmentID IS NULL;

ALTER TABLE `Certificate`
  ADD CONSTRAINT `fk_certificate_enrollment` FOREIGN KEY (`EnrollmentID`) REFERENCES `Enrollment`(`EnrollmentID`)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- -----------------------
-- PasswordResetToken
-- -----------------------

-- Rename legacy column if present (manual)
-- ALTER TABLE `PasswordResetToken` CHANGE COLUMN `ExpiryDate` `ExpiresAt` DATETIME NOT NULL;

ALTER TABLE `PasswordResetToken`
  ADD COLUMN IF NOT EXISTS `ExpiresAt` DATETIME NOT NULL;

-- -----------------------
-- Data cleanup
-- -----------------------

-- Normalize legacy payment statuses (if any)
UPDATE `Payment`
   SET `PaymentStatus` = 'Paid'
 WHERE `PaymentStatus` = 'Success';
