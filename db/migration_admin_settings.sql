-- Migration: add AppSetting table and initial phase-1 defaults
USE `psm_elearning`;

CREATE TABLE IF NOT EXISTS `AppSetting` (
  `SettingKey` VARCHAR(120) PRIMARY KEY,
  `SettingValue` TEXT NULL,
  `UpdatedBy` INT NULL,
  `CreatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_app_setting_updated_by` FOREIGN KEY (`UpdatedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `AppSettingAudit` (
  `AuditID` INT AUTO_INCREMENT PRIMARY KEY,
  `SettingKey` VARCHAR(120) NOT NULL,
  `OldValue` TEXT NULL,
  `NewValue` TEXT NULL,
  `ChangedBy` INT NULL,
  `ChangedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_app_setting_audit_key` (`SettingKey`),
  KEY `idx_app_setting_audit_changed_at` (`ChangedAt`),
  CONSTRAINT `fk_app_setting_audit_setting_key` FOREIGN KEY (`SettingKey`) REFERENCES `AppSetting`(`SettingKey`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_app_setting_audit_changed_by` FOREIGN KEY (`ChangedBy`) REFERENCES `User`(`UserID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `AppSetting` (`SettingKey`, `SettingValue`) VALUES
  ('platform.name', 'PSM E-Learning Platform'),
  ('platform.supportEmail', 'support@psm-elearning.com'),
  ('platform.timezone', 'Africa/Lagos'),
  ('security.sessionTimeoutMinutes', '30'),
  ('security.minPasswordLength', '8'),
  ('payment.mode', 'LIVE'),
  ('payment.currency', 'NGN'),
  ('enrollment.autoActivateOnPayment', 'true'),
  ('learning.completionMaterialPercent', '100'),
  ('assessment.defaultPassMark', '70'),
  ('assessment.defaultMaxAttempts', '3')
ON DUPLICATE KEY UPDATE
  `SettingValue` = VALUES(`SettingValue`);
