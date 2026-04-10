-- Migration: Move assessment placement metadata out of Instructions into dedicated columns
-- Target: MySQL 8.0+

USE `psm_elearning`;

ALTER TABLE `Assessment`
  ADD COLUMN IF NOT EXISTS `PlacementType` VARCHAR(20) NOT NULL DEFAULT 'final',
  ADD COLUMN IF NOT EXISTS `PlacementMaterialID` INT NULL;

ALTER TABLE `Assessment`
  ADD INDEX IF NOT EXISTS `idx_assessment_placement_material` (`PlacementMaterialID`);

UPDATE `Assessment`
   SET `PlacementType` = CASE
         WHEN `Instructions` REGEXP '##PLACEMENT:afterMaterial:[0-9]+##' THEN 'afterMaterial'
         ELSE 'final'
       END
 WHERE `PlacementType` IS NULL OR TRIM(`PlacementType`) = '';

UPDATE `Assessment`
   SET `PlacementMaterialID` = CASE
         WHEN `Instructions` REGEXP '##PLACEMENT:afterMaterial:[0-9]+##'
           THEN CAST(
             REPLACE(
               REPLACE(
                 REGEXP_SUBSTR(`Instructions`, '##PLACEMENT:afterMaterial:[0-9]+##'),
                 '##PLACEMENT:afterMaterial:',
                 ''
               ),
               '##',
               ''
             ) AS UNSIGNED
           )
         ELSE NULL
       END
 WHERE `PlacementMaterialID` IS NULL;

UPDATE `Assessment`
   SET `Instructions` = TRIM(REPLACE(`Instructions`, REGEXP_SUBSTR(`Instructions`, '##PLACEMENT:[^#]+##'), ''))
 WHERE `Instructions` REGEXP '##PLACEMENT:[^#]+##';

ALTER TABLE `Assessment`
  ADD CONSTRAINT `fk_assessment_placement_material` FOREIGN KEY (`PlacementMaterialID`) REFERENCES `Material`(`MaterialID`)
  ON DELETE SET NULL ON UPDATE CASCADE;
