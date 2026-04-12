-- Adds per-assessment grading mode control for instructor-managed vs auto grading.
-- Run this once on existing databases.

ALTER TABLE `Assessment`
  ADD COLUMN IF NOT EXISTS `GradingMode` VARCHAR(20) NOT NULL DEFAULT 'auto' AFTER `Type`;

-- Backfill existing rows with sensible defaults.
UPDATE `Assessment`
SET `GradingMode` = CASE
  WHEN LOWER(COALESCE(`Type`, '')) = 'assignment' THEN 'manual'
  ELSE 'auto'
END
WHERE `GradingMode` IS NULL OR TRIM(`GradingMode`) = '';
