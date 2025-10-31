-- Change OrangeHRM date format to US format (mm-dd-yyyy)

-- Update the configuration to use m-d-Y format
UPDATE ohrm_config
SET value = 'm-d-Y'
WHERE name = 'admin.localization.default_date_format';

-- If the record doesn't exist, insert it
INSERT IGNORE INTO ohrm_config (name, value)
VALUES ('admin.localization.default_date_format', 'm-d-Y');
