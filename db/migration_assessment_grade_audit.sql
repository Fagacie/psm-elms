-- Audit trail for assessment grading and regrading.

CREATE TABLE IF NOT EXISTS `AssessmentGradeAudit` (
  `AuditID` INT AUTO_INCREMENT PRIMARY KEY,
  `SubmissionID` INT NOT NULL,
  `AssessmentID` INT NOT NULL,
  `ActionType` VARCHAR(40) NOT NULL,
  `OldScore` DECIMAL(5,2) NULL,
  `NewScore` DECIMAL(5,2) NULL,
  `OldFeedback` TEXT NULL,
  `NewFeedback` TEXT NULL,
  `GradedBy` INT NULL,
  `GradedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Note` TEXT NULL,
  KEY `idx_grade_audit_submission` (`SubmissionID`),
  KEY `idx_grade_audit_assessment` (`AssessmentID`),
  KEY `idx_grade_audit_graded_by` (`GradedBy`),
  CONSTRAINT `fk_grade_audit_submission` FOREIGN KEY (`SubmissionID`) REFERENCES `AssessmentSubmission`(`SubmissionID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_grade_audit_assessment` FOREIGN KEY (`AssessmentID`) REFERENCES `Assessment`(`AssessmentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_grade_audit_graded_by` FOREIGN KEY (`GradedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
