-- OrangeHRM Database Initialization
-- This script creates the database and user for OrangeHRM

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS orangehrm_mysql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'orangehrm'@'%' IDENTIFIED BY 'orangehrm123';

-- Grant privileges
GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Use the database
USE orangehrm_mysql;

-- Set SQL mode for compatibility
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
