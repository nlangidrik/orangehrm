# Replace OrangeHRM Logo with Your Company Logo
# PowerShell Script for Windows

param(
    [Parameter(Mandatory=$true)]
    [string]$LogoPath
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Replace OrangeHRM Logo with PSS Logo" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if logo file exists
if (-not (Test-Path $LogoPath)) {
    Write-Host "Error: Logo file not found at: $LogoPath" -ForegroundColor Red
    exit 1
}

Write-Host "Using logo file: $LogoPath" -ForegroundColor Green
Write-Host ""

# Get file extension
$extension = [System.IO.Path]::GetExtension($LogoPath)

# Create temporary directory
$tempDir = "$env:TEMP\orangehrm_logos"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "Converting logo to required formats..." -ForegroundColor Yellow

# Convert logo to different formats using PowerShell
# For favicon, we'll copy the original and let the browser handle it
Copy-Item $LogoPath "$tempDir\favicon.ico"
Copy-Item $LogoPath "$tempDir\logo.png"
Copy-Item $LogoPath "$tempDir\ohrm_branding.png"
Copy-Item $LogoPath "$tempDir\orangehrm-logo.png"
Copy-Item $LogoPath "$tempDir\ohrm_logo.png"

Write-Host "Copying logos to Docker container..." -ForegroundColor Yellow

# Copy to Docker container
docker cp "$tempDir\favicon.ico" orangehrm_app:/var/www/html/src/client/public/favicon.ico
docker cp "$tempDir\favicon.ico" orangehrm_app:/var/www/html/installer/client/public/favicon.ico
docker cp "$tempDir\logo.png" orangehrm_app:/var/www/html/web/images/logo.png
docker cp "$tempDir\ohrm_branding.png" orangehrm_app:/var/www/html/web/images/ohrm_branding.png
docker cp "$tempDir\orangehrm-logo.png" orangehrm_app:/var/www/html/web/images/orangehrm-logo.png
docker cp "$tempDir\ohrm_logo.png" orangehrm_app:/var/www/html/web/images/ohrm_logo.png

Write-Host "Restarting OrangeHRM container..." -ForegroundColor Yellow
docker-compose -f docker-compose.simple.yml restart orangehrm

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "  Logo Replacement Complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Clear your browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "2. Refresh http://localhost:8080" -ForegroundColor White
Write-Host "3. Check the favicon and logos" -ForegroundColor White
Write-Host ""
Write-Host "Files replaced:" -ForegroundColor Cyan
Write-Host "  - favicon.ico (browser tab icon)" -ForegroundColor White
Write-Host "  - logo.png (header logo)" -ForegroundColor White
Write-Host "  - ohrm_branding.png (login page)" -ForegroundColor White
Write-Host ""

# Cleanup
Remove-Item -Recurse -Force $tempDir

Write-Host "Done! 🎉" -ForegroundColor Green
