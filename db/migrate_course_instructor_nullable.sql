-- ============================================================
-- MIGRATION: Make Course.InstructorID nullable
-- REASON: Admin dashboard can create courses without an assigned
--         instructor. The previous NOT NULL constraint caused a
--         silent INSERT failure every time the instructor field
--         was left blank.
-- ============================================================

USE psm_elearning;

-- Step 1: Drop the existing FK constraint (required before altering column)
ALTER TABLE `Course`
    DROP FOREIGN KEY `fk_course_instructor`;

-- Step 2: Make InstructorID nullable
ALTER TABLE `Course`
    MODIFY COLUMN `InstructorID` INT NULL;

-- Step 3: Re-add FK with SET NULL on delete (safe — unassigned course stays intact)
ALTER TABLE `Course`
    ADD CONSTRAINT `fk_course_instructor`
    FOREIGN KEY (`InstructorID`) REFERENCES `Instructor`(`UserID`)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- Verify
SHOW CREATE TABLE `Course`;
