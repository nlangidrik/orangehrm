-- OrangeHRM Position Feature Migration
-- Adds Position management similar to Job Titles

-- Create ohrm_position table
CREATE TABLE IF NOT EXISTS `ohrm_position` (
  `id` INT(13) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(400) DEFAULT NULL,
  `note` VARCHAR(400) DEFAULT NULL,
  `is_deleted` TINYINT(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`, `is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add position_id column to hs_hr_employee table (if not exists)
SET @column_exists = (
  SELECT COUNT(*) 
  FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'hs_hr_employee' 
  AND COLUMN_NAME = 'position_id'
);

SET @sql = IF(@column_exists = 0, 
  'ALTER TABLE `hs_hr_employee` ADD COLUMN `position_id` INT(13) DEFAULT NULL AFTER `job_title_code`, ADD KEY `position_id` (`position_id`), ADD CONSTRAINT `fk_hs_hr_employee_position` FOREIGN KEY (`position_id`) REFERENCES `ohrm_position` (`id`) ON DELETE SET NULL', 
  'SELECT "Column position_id already exists"'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Get Job menu parent ID
SET @job_menu_id := (SELECT `id` FROM ohrm_menu_item WHERE `menu_title` = 'Job' AND `level` = 2);

-- Create screen for Positions (if not exists)
INSERT IGNORE INTO `ohrm_screen` (`name`, `module_id`, `action_url`, `menu_configurator`)
VALUES ('Positions', (SELECT id FROM ohrm_module WHERE name = 'admin'), 'viewPositionList', 'OrangeHRM\\Admin\\Menu\\PositionMenuConfigurator');

-- Get Position screen ID
SET @position_screen_id := (SELECT id FROM ohrm_screen WHERE name = 'Positions' AND module_id = (SELECT id FROM ohrm_module WHERE name = 'admin'));

-- Add Positions menu item under Job (after Job Titles at order_hint 150)
INSERT IGNORE INTO `ohrm_menu_item` (`menu_title`, `screen_id`, `parent_id`, `level`, `order_hint`, `status`)
VALUES ('Positions', @position_screen_id, @job_menu_id, 3, 150, 1);

-- Add user role screen permissions (same as Job Titles)
-- Admin role
INSERT IGNORE INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (1, @position_screen_id, 1, 1, 1, 1);

-- ESS role (read only)
INSERT IGNORE INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (2, @position_screen_id, 1, 0, 0, 0);

-- Supervisor role (read only)
INSERT IGNORE INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (3, @position_screen_id, 1, 0, 0, 0);

