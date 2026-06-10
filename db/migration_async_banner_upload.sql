-- Migration: add BannerUploadStatus column to Course table
-- Tracks the state of the async Cloudinary banner upload.
-- Values: NULL (no upload initiated), 'pending', 'uploaded', 'failed'
-- Safe to run multiple times (IF NOT EXISTS guard via information_schema check).

ALTER TABLE `Course`
  ADD COLUMN IF NOT EXISTS `BannerUploadStatus` VARCHAR(20) NULL
    COMMENT 'Async upload state: pending, uploaded, failed'
    AFTER `CourseBanner`;
