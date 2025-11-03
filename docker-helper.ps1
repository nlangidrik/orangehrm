# OrangeHRM Docker Helper Script
# Makes it easy to manage your OrangeHRM Docker setup

param(
    [Parameter(Position=0)]
    [ValidateSet('start', 'stop', 'restart', 'rebuild', 'reset', 'backup', 'restore', 'logs', 'status', 'clean')]
    [string]$Action = 'status',
    
    [Parameter(Position=1)]
    [string]$File = ''
)

function Show-Help {
    Write-Host "OrangeHRM Docker Helper" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\docker-helper.ps1 [action] [file]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Actions:" -ForegroundColor Green
    Write-Host "  start     - Start containers (keeps data)" -ForegroundColor White
    Write-Host "  stop      - Stop containers (keeps data)" -ForegroundColor White
    Write-Host "  restart   - Restart containers (keeps data)" -ForegroundColor White
    Write-Host "  rebuild   - Rebuild and restart (keeps data)" -ForegroundColor White
    Write-Host "  reset     - Reset everything (DELETES ALL DATA)" -ForegroundColor Red
    Write-Host "  backup    - Backup database to file" -ForegroundColor White
    Write-Host "  restore   - Restore database from file" -ForegroundColor White
    Write-Host "  logs      - Show application logs" -ForegroundColor White
    Write-Host "  status    - Show container and volume status" -ForegroundColor White
    Write-Host "  clean     - Remove stopped containers and unused volumes" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\docker-helper.ps1 start" -ForegroundColor Gray
    Write-Host "  .\docker-helper.ps1 rebuild" -ForegroundColor Gray
    Write-Host "  .\docker-helper.ps1 backup mybackup.sql" -ForegroundColor Gray
    Write-Host "  .\docker-helper.ps1 restore mybackup.sql" -ForegroundColor Gray
}

function Start-Containers {
    Write-Host "Starting OrangeHRM containers..." -ForegroundColor Green
    docker compose up -d
    Write-Host "✓ Containers started!" -ForegroundColor Green
    Write-Host "Access OrangeHRM at: http://localhost:8080" -ForegroundColor Cyan
}

function Stop-Containers {
    Write-Host "Stopping OrangeHRM containers..." -ForegroundColor Yellow
    docker compose down
    Write-Host "✓ Containers stopped (data preserved)" -ForegroundColor Green
}

function Restart-Containers {
    Write-Host "Restarting OrangeHRM containers..." -ForegroundColor Yellow
    Stop-Containers
    Start-Sleep -Seconds 2
    Start-Containers
}

function Rebuild-Containers {
    Write-Host "Rebuilding OrangeHRM containers..." -ForegroundColor Yellow
    Write-Host "This will rebuild the images but keep your data!" -ForegroundColor Cyan
    docker compose down
    docker compose up -d --build
    Write-Host "✓ Rebuild complete!" -ForegroundColor Green
    Write-Host "Access OrangeHRM at: http://localhost:8080" -ForegroundColor Cyan
}

function Reset-Everything {
    Write-Host "WARNING: This will DELETE ALL DATA!" -ForegroundColor Red
    $confirm = Read-Host "Type 'yes' to confirm"
    if ($confirm -eq 'yes') {
        Write-Host "Removing all containers and volumes..." -ForegroundColor Red
        docker compose down -v
        Write-Host "✓ Everything removed. Run 'start' to begin fresh." -ForegroundColor Green
    } else {
        Write-Host "Reset cancelled." -ForegroundColor Yellow
    }
}

function Backup-Database {
    param([string]$BackupFile)
    
    if ([string]::IsNullOrEmpty($BackupFile)) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $BackupFile = "orangehrm_backup_$timestamp.sql"
    }
    
    Write-Host "Creating database backup..." -ForegroundColor Green
    $password = "orangehrm123"
    docker exec orangehrm_mysql mysqladmin ping -h localhost -u orangehrm -p$password 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        docker exec orangehrm_mysql mysqldump -u orangehrm -p$password orangehrm_mysql > $BackupFile
        Write-Host "✓ Backup created: $BackupFile" -ForegroundColor Green
    } else {
        Write-Host "✗ Database container not running!" -ForegroundColor Red
    }
}

function Restore-Database {
    param([string]$BackupFile)
    
    if ([string]::IsNullOrEmpty($BackupFile)) {
        Write-Host "Error: Please specify a backup file" -ForegroundColor Red
        Write-Host "Usage: .\docker-helper.ps1 restore mybackup.sql" -ForegroundColor Yellow
        return
    }
    
    if (-not (Test-Path $BackupFile)) {
        Write-Host "Error: Backup file not found: $BackupFile" -ForegroundColor Red
        return
    }
    
    Write-Host "Restoring database from $BackupFile..." -ForegroundColor Green
    $password = "orangehrm123"
    Get-Content $BackupFile | docker exec -i orangehrm_mysql mysql -u orangehrm -p$password orangehrm_mysql
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Database restored successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Restore failed!" -ForegroundColor Red
    }
}

function Show-Logs {
    Write-Host "Showing OrangeHRM application logs (Ctrl+C to exit)..." -ForegroundColor Cyan
    docker logs orangehrm_app -f
}

function Show-Status {
    Write-Host "OrangeHRM Docker Status" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Containers:" -ForegroundColor Green
    docker compose ps
    Write-Host ""
    
    Write-Host "Volumes:" -ForegroundColor Green
    docker volume ls | Select-String "orangehrm"
    Write-Host ""
    
    Write-Host "Access URLs:" -ForegroundColor Green
    Write-Host "  OrangeHRM: http://localhost:8080" -ForegroundColor White
    Write-Host "  Direct:    http://localhost:80" -ForegroundColor White
    Write-Host "  MySQL:     localhost:3306" -ForegroundColor White
    Write-Host ""
}

function Clean-Docker {
    Write-Host "Cleaning up Docker resources..." -ForegroundColor Yellow
    Write-Host "Removing stopped containers..." -ForegroundColor Gray
    docker container prune -f
    Write-Host "Removing unused volumes..." -ForegroundColor Gray
    docker volume prune -f
    Write-Host "✓ Cleanup complete!" -ForegroundColor Green
}

# Main script execution
switch ($Action) {
    'start'   { Start-Containers }
    'stop'    { Stop-Containers }
    'restart' { Restart-Containers }
    'rebuild' { Rebuild-Containers }
    'reset'   { Reset-Everything }
    'backup'  { Backup-Database -BackupFile $File }
    'restore' { Restore-Database -BackupFile $File }
    'logs'    { Show-Logs }
    'status'  { Show-Status }
    'clean'   { Clean-Docker }
    default   { Show-Help }
}

