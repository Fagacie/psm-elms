-- Adds per-assessment submission mode control for file/text/both assignment workflows.
-- Run this once on existing databases.

ALTER TABLE `Assessment`
  ADD COLUMN IF NOT EXISTS `SubmissionMode` VARCHAR(20) NOT NULL DEFAULT 'both' AFTER `GradingMode`;

-- Backfill existing rows with the current default workflow.
UPDATE `Assessment`
SET `SubmissionMode` = 'both'
WHERE `SubmissionMode` IS NULL OR TRIM(`SubmissionMode`) = '';
