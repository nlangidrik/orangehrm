@echo off
REM OrangeHRM Database Backup Script (Windows Batch)
REM This script creates a backup of the orangehrm_mysql database

setlocal enabledelayedexpansion

set BACKUP_DIR=backups
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=%BACKUP_DIR%\orangehrm_backup_%TIMESTAMP%.sql

REM Create backups directory if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo Starting database backup...
echo Backup file: %BACKUP_FILE%

REM Run the backup
docker exec orangehrm_mysql mysqldump -uorangehrm -porangehrm123 --no-tablespaces orangehrm_mysql > "%BACKUP_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Backup completed successfully!
    echo File: %BACKUP_FILE%
    echo.
    echo To restore this backup, run:
    echo Get-Content %BACKUP_FILE% ^| docker exec -i orangehrm_mysql mysql -uorangehrm -porangehrm123 orangehrm_mysql
) else (
    echo.
    echo Backup failed! Please check the error messages above.
    exit /b 1
)

endlocal

