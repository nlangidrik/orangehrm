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

-- Add position_id column to hs_hr_employee table
ALTER TABLE `hs_hr_employee` 
ADD COLUMN `position_id` INT(13) DEFAULT NULL AFTER `job_title_code`,
ADD KEY `position_id` (`position_id`),
ADD CONSTRAINT `fk_hs_hr_employee_position` 
  FOREIGN KEY (`position_id`) 
  REFERENCES `ohrm_position` (`id`) 
  ON DELETE SET NULL;

-- Get Job menu parent ID
SET @job_menu_id := (SELECT `id` FROM ohrm_menu_item WHERE `menu_title` = 'Job' AND `level` = 2);

-- Create screen for Positions
INSERT INTO `ohrm_screen` (`name`, `module_id`, `action_url`, `menu_configurator`)
VALUES ('Positions', (SELECT id FROM ohrm_module WHERE name = 'admin'), 'viewPositionList', 'OrangeHRM\\Admin\\Menu\\PositionMenuConfigurator');

SET @position_screen_id := LAST_INSERT_ID();

-- Add Positions menu item under Job (after Job Titles at order_hint 150)
INSERT INTO `ohrm_menu_item` (`menu_title`, `screen_id`, `parent_id`, `level`, `order_hint`, `url_extras`, `status`)
VALUES ('Positions', @position_screen_id, @job_menu_id, 3, 150, NULL, 1);

-- Add user role screen permissions (same as Job Titles)
-- Admin role
INSERT INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (1, @position_screen_id, 1, 1, 1, 1);

-- ESS role (read only)
INSERT INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (2, @position_screen_id, 1, 0, 0, 0);

-- Supervisor role (read only)
INSERT INTO `ohrm_user_role_screen` (`user_role_id`, `screen_id`, `can_read`, `can_create`, `can_update`, `can_delete`)
VALUES (3, @position_screen_id, 1, 0, 0, 0);

