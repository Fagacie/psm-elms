-- Migration: Database cleanup of unused columns and legacy attributes
-- Safe to run multiple times (uses IF EXISTS where supported).
-- Run via MySQL CLI: SOURCE db/migration_db_cleanup.sql;

-- ============================================================
-- 1. Student table — remove legacy unused columns
-- ============================================================
ALTER TABLE Student
    DROP COLUMN IF EXISTS parent_email;

-- ============================================================
-- 2. User table — remove unused last_active tracking column
--    (activity is tracked via session and enrollment timestamps)
-- ============================================================
ALTER TABLE User
    DROP COLUMN IF EXISTS last_active;

-- ============================================================
-- 3. MaterialProgress table — remove unused free-text column
--    (notes are never queried; completion status is sufficient)
-- ============================================================
ALTER TABLE MaterialProgress
    DROP COLUMN IF EXISTS progress_notes;

-- ============================================================
-- 4. AppSetting — ensure new platform keys have defaults
--    (idempotent: INSERT IGNORE will not overwrite existing)
-- ============================================================
INSERT IGNORE INTO AppSetting (SettingKey, SettingValue)
VALUES
  ('platform.youtubeApiKey',  ''),
  ('platform.maxFileUploadMB', '50'),
  ('platform.certificateEnabled', 'true');

-- ============================================================
-- 5. AssessmentSubmission — update AnswersFilePath to TEXT
--    to support larger MCQ payload structures without truncation
-- ============================================================
ALTER TABLE AssessmentSubmission MODIFY COLUMN AnswersFilePath TEXT NULL;
