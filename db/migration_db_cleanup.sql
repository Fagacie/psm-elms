-- Migration: Database cleanup of unused columns and legacy attributes
-- Safe to run multiple times (uses IF EXISTS where supported).
-- Run via MySQL CLI: SOURCE db/migration_db_cleanup.sql;

-- ============================================================
-- 1. students table — remove legacy unused columns
-- ============================================================
ALTER TABLE students
    DROP COLUMN IF EXISTS emergency_contact,
    DROP COLUMN IF EXISTS parent_email;

-- ============================================================
-- 2. users table — remove unused last_active tracking column
--    (activity is tracked via session and enrollment timestamps)
-- ============================================================
ALTER TABLE users
    DROP COLUMN IF EXISTS last_active;

-- ============================================================
-- 3. material_progress table — remove unused free-text column
--    (notes are never queried; completion status is sufficient)
-- ============================================================
ALTER TABLE material_progress
    DROP COLUMN IF EXISTS progress_notes;

-- ============================================================
-- 4. app_settings — ensure new platform keys have defaults
--    (idempotent: INSERT IGNORE will not overwrite existing)
-- ============================================================
INSERT IGNORE INTO app_settings (setting_key, setting_value, description, is_secret)
VALUES
  ('platform.youtubeApiKey',  '',   'Optional YouTube Data API key for extended video features', 0),
  ('platform.maxFileUploadMB', '50', 'Maximum allowed file upload size in megabytes',              0),
  ('platform.certificateEnabled', 'true', 'Enable or disable certificate issuance for completed courses', 0);

-- ============================================================
-- 5. AssessmentSubmission — update AnswersFilePath to TEXT
--    to support larger MCQ payload structures without truncation
-- ============================================================
ALTER TABLE AssessmentSubmission MODIFY COLUMN AnswersFilePath TEXT NULL;

-- ============================================================
-- Done
-- ============================================================
