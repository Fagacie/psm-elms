-- Ordered migration runner for existing environments.
-- Run this after db/schema.sql when upgrading an existing database.

SOURCE db/migration_align_schema.sql;
SOURCE db/migration_admin_settings.sql;
SOURCE db/migration_instructor_application_storage.sql;
SOURCE db/migration_assessment_placement.sql;
SOURCE db/migration_assessment_grading_mode.sql;
SOURCE db/migration_assessment_submission_mode.sql;
SOURCE db/migration_assessment_grade_audit.sql;
SOURCE db/migration_paystack.sql;
SOURCE db/migration_db_cleanup.sql;
