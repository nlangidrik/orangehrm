-- OrangeHRM Position Field Migration
-- Changes Position from dropdown (foreign key) to free text field

-- Add position_name column to hs_hr_employee table (if not exists)
SET @column_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'hs_hr_employee' 
  AND COLUMN_NAME = 'position_name'
);

SET @sql = IF(@column_exists = 0, 
  'ALTER TABLE `hs_hr_employee` ADD COLUMN `position_name` VARCHAR(100) DEFAULT NULL AFTER `job_title_code`', 
  'SELECT "Column position_name already exists"'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Migrate existing position data from position_id to position_name (if position_id exists)
SET @position_id_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'hs_hr_employee' 
  AND COLUMN_NAME = 'position_id'
);

SET @migrate_sql = IF(@position_id_exists > 0, 
  'UPDATE `hs_hr_employee` e 
   INNER JOIN `ohrm_position` p ON e.position_id = p.id 
   SET e.position_name = p.name 
   WHERE e.position_id IS NOT NULL AND e.position_name IS NULL', 
  'SELECT "No position_id column to migrate from"'
);

PREPARE migrate_stmt FROM @migrate_sql;
EXECUTE migrate_stmt;
DEALLOCATE PREPARE migrate_stmt;

-- Remove foreign key constraint (if exists)
SET @fk_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
  WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'hs_hr_employee' 
  AND CONSTRAINT_NAME = 'fk_hs_hr_employee_position'
);

SET @drop_fk_sql = IF(@fk_exists > 0, 
  'ALTER TABLE `hs_hr_employee` DROP FOREIGN KEY `fk_hs_hr_employee_position`', 
  'SELECT "Foreign key constraint does not exist"'
);

PREPARE drop_fk_stmt FROM @drop_fk_sql;
EXECUTE drop_fk_stmt;
DEALLOCATE PREPARE drop_fk_stmt;

-- Drop position_id column (if exists)
SET @drop_col_sql = IF(@position_id_exists > 0, 
  'ALTER TABLE `hs_hr_employee` DROP COLUMN `position_id`', 
  'SELECT "Column position_id does not exist"'
);

PREPARE drop_col_stmt FROM @drop_col_sql;
EXECUTE drop_col_stmt;
DEALLOCATE PREPARE drop_col_stmt;

