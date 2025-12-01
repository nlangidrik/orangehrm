# OrangeHRM Complete Backup Script
# This script creates a backup of the database AND file uploads (employee photos)

$BackupDir = ".\backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = "$BackupDir\orangehrm_backup_$Timestamp.sql"
$PhotosBackupFile = "$BackupDir\orangehrm_photos_$Timestamp.tar.gz"

# Create backups directory if it doesn't exist
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Write-Host "Created backups directory: $BackupDir" -ForegroundColor Green
}

Write-Host "Starting complete backup (database + file uploads)..." -ForegroundColor Yellow
Write-Host "Backup files:" -ForegroundColor Cyan
Write-Host "  Database: $BackupFile" -ForegroundColor Cyan
Write-Host "  Photos: $PhotosBackupFile" -ForegroundColor Cyan

# Backup database
Write-Host "`nBacking up database..." -ForegroundColor Yellow
docker exec orangehrm_mysql mysqldump -uorangehrm -porangehrm123 --no-tablespaces orangehrm_mysql > $BackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nDatabase backup failed! Please check the error messages above." -ForegroundColor Red
    exit 1
}

# Backup employee photos
Write-Host "Backing up employee photos..." -ForegroundColor Yellow
docker exec orangehrm_app bash -c "cd /var/www/html/src/plugins/orangehrmPimPlugin/public/webroot && tar -czf - photos 2>/dev/null" > $PhotosBackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: Could not backup employee photos. They may not exist yet." -ForegroundColor Yellow
    Remove-Item $PhotosBackupFile -ErrorAction SilentlyContinue
    $PhotosBackupFile = $null
}

# Summary
$DbSize = (Get-Item $BackupFile).Length / 1MB
Write-Host "`nBackup completed successfully!" -ForegroundColor Green
Write-Host "Database backup: $BackupFile ($([math]::Round($DbSize, 2)) MB)" -ForegroundColor Cyan
if ($PhotosBackupFile -and (Test-Path $PhotosBackupFile)) {
    $PhotosSize = (Get-Item $PhotosBackupFile).Length / 1MB
    Write-Host "Photos backup: $PhotosBackupFile ($([math]::Round($PhotosSize, 2)) MB)" -ForegroundColor Cyan
}
Write-Host "`nTo restore this backup, run:" -ForegroundColor Yellow
Write-Host ".\restore-database.ps1 -BackupFile `"$BackupFile`"" -ForegroundColor White

