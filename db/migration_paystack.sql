-- Migration Script: Add Paystack Integration to Existing Database
-- Run this ONLY if you already have the database with old schema
-- This will add the new columns without dropping existing data

USE psm_elearning;

-- Update Enrollment table
ALTER TABLE `Enrollment` 
  MODIFY COLUMN `Status` ENUM('Pending','Active','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  ADD COLUMN IF NOT EXISTS `PaymentStatus` ENUM('Pending','Paid','Failed') NOT NULL DEFAULT 'Pending' AFTER `Status`,
  ADD COLUMN IF NOT EXISTS `PaymentRef` VARCHAR(100) NULL AFTER `PaymentStatus`,
  ADD COLUMN IF NOT EXISTS `UpdatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `EnrolledAt`,
  ADD COLUMN IF NOT EXISTS `CompletionStatus` ENUM('Not Started','In Progress','Completed') NOT NULL DEFAULT 'Not Started' AFTER `UpdatedAt`;

-- Add index for PaymentStatus (ignore if exists)
ALTER TABLE `Enrollment` ADD INDEX IF NOT EXISTS `idx_enrollment_payment_status` (`PaymentStatus`);

-- Update Payment table
ALTER TABLE `Payment`
  MODIFY COLUMN `Status` ENUM('Pending','Paid','Failed','Refunded','Abandoned') NOT NULL DEFAULT 'Pending',
  ADD COLUMN IF NOT EXISTS `PaymentRef` VARCHAR(100) NULL AFTER `PaidAt`,
  ADD COLUMN IF NOT EXISTS `PaystackReference` VARCHAR(255) NULL AFTER `PaymentRef`,
  ADD COLUMN IF NOT EXISTS `AccessCode` VARCHAR(255) NULL AFTER `PaystackReference`,
  ADD COLUMN IF NOT EXISTS `AuthorizationUrl` TEXT NULL AFTER `AccessCode`,
  ADD COLUMN IF NOT EXISTS `PaystackStatus` VARCHAR(50) NULL AFTER `AuthorizationUrl`;

-- Add unique constraints (ignore if exists)
ALTER TABLE `Payment` ADD UNIQUE KEY IF NOT EXISTS `uk_payment_ref` (`PaymentRef`);
ALTER TABLE `Payment` ADD UNIQUE KEY IF NOT EXISTS `uk_paystack_ref` (`PaystackReference`);

-- Show updated table structures
DESCRIBE Enrollment;
DESCRIBE Payment;

SELECT 'Migration completed successfully!' AS Status;
