# OrangeHRM Complete Restore Script
# This script restores a database backup AND file uploads (employee photos)

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupFile,
    [Parameter(Mandatory=$false)]
    [string]$PhotosBackupFile
)

if (-not (Test-Path $BackupFile)) {
    Write-Host "Error: Backup file not found: $BackupFile" -ForegroundColor Red
    exit 1
}

# Try to find matching photos backup if not provided
if (-not $PhotosBackupFile) {
    $BackupBaseName = [System.IO.Path]::GetFileNameWithoutExtension($BackupFile)
    $BackupDir = Split-Path $BackupFile
    $Timestamp = $BackupBaseName -replace 'orangehrm_backup_', ''
    $PossiblePhotosFile = Join-Path $BackupDir "orangehrm_photos_$Timestamp.tar.gz"
    if (Test-Path $PossiblePhotosFile) {
        $PhotosBackupFile = $PossiblePhotosFile
        Write-Host "Found matching photos backup: $PhotosBackupFile" -ForegroundColor Green
    }
}

Write-Host "WARNING: This will overwrite your current database and file uploads!" -ForegroundColor Red
Write-Host "Press Ctrl+C to cancel, or any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`nStarting restore..." -ForegroundColor Yellow
Write-Host "Database backup: $BackupFile" -ForegroundColor Cyan
if ($PhotosBackupFile) {
    Write-Host "Photos backup: $PhotosBackupFile" -ForegroundColor Cyan
} else {
    Write-Host "Photos backup: Not found (will skip)" -ForegroundColor Yellow
}

# Create a temporary backup before restoring
$TempBackup = ".\backups\pre_restore_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
Write-Host "`nCreating safety backup before restore..." -ForegroundColor Yellow
docker exec orangehrm_mysql mysqldump -uorangehrm -porangehrm123 --no-tablespaces orangehrm_mysql > $TempBackup

if ($LASTEXITCODE -eq 0) {
    Write-Host "Safety backup created: $TempBackup" -ForegroundColor Green
} else {
    Write-Host "Warning: Could not create safety backup. Continuing anyway..." -ForegroundColor Yellow
}

# Restore the database
Write-Host "`nRestoring database..." -ForegroundColor Yellow
Get-Content $BackupFile | docker exec -i orangehrm_mysql mysql -uorangehrm -porangehrm123 orangehrm_mysql

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nDatabase restore failed! Please check the error messages above." -ForegroundColor Red
    Write-Host "You can restore the safety backup if needed." -ForegroundColor Yellow
    exit 1
}

# Restore employee photos if backup exists
if ($PhotosBackupFile -and (Test-Path $PhotosBackupFile)) {
    Write-Host "`nRestoring employee photos..." -ForegroundColor Yellow
    Get-Content $PhotosBackupFile | docker exec -i orangehrm_app bash -c "cd /var/www/html/src/plugins/orangehrmPimPlugin/public/webroot && tar -xzf - 2>/dev/null && chown -R www-data:www-data photos 2>/dev/null || true"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Employee photos restored successfully!" -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not restore employee photos. They may not exist in the backup." -ForegroundColor Yellow
    }
}

Write-Host "`nRestore completed successfully!" -ForegroundColor Green

