# Update OrangeHRM Branding to PSS
# PowerShell Script

param(
    [string]$FaviconPath = ""
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Update OrangeHRM Branding to PSSHRM" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Update title and templates
Write-Host "✓ Updating page title to PSSHRM..." -ForegroundColor Green
docker cp src/plugins/orangehrmCorePlugin/templates/base.html.twig orangehrm_app:/var/www/html/src/plugins/orangehrmCorePlugin/templates/base.html.twig

# Update custom CSS
Write-Host "✓ Applying custom styles (hiding Upgrade button)..." -ForegroundColor Green
docker cp custom-styles.css orangehrm_app:/var/www/html/web/custom-styles.css

# Update favicon if provided
if ($FaviconPath -and (Test-Path $FaviconPath)) {
    Write-Host "✓ Updating favicon..." -ForegroundColor Green
    docker cp $FaviconPath orangehrm_app:/var/www/html/src/client/public/favicon.ico
    docker cp $FaviconPath orangehrm_app:/var/www/html/installer/client/public/favicon.ico
    docker cp $FaviconPath orangehrm_app:/var/www/html/web/images/logo.png
    docker cp $FaviconPath orangehrm_app:/var/www/html/web/images/ohrm_branding.png
    docker cp $FaviconPath orangehrm_app:/var/www/html/web/images/orangehrm-logo.png
    docker cp $FaviconPath orangehrm_app:/var/www/html/web/images/ohrm_logo.png
} else {
    Write-Host "⚠ No favicon provided. To add favicon, run:" -ForegroundColor Yellow
    Write-Host "  .\update-branding.ps1 -FaviconPath 'C:\path\to\your\logo.png'" -ForegroundColor Yellow
}

# Clear cache
Write-Host "✓ Clearing application cache..." -ForegroundColor Green
docker exec orangehrm_app rm -rf /var/www/html/src/cache/* 2>$null

# Restart container
Write-Host "✓ Restarting OrangeHRM..." -ForegroundColor Green
docker-compose -f docker-compose.simple.yml restart orangehrm | Out-Null
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "  Branding Updated Successfully!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Changes Applied:" -ForegroundColor Cyan
Write-Host "  ✓ Page title changed to 'PSSHRM'" -ForegroundColor White
Write-Host "  ✓ Upgrade button hidden" -ForegroundColor White
if ($FaviconPath) {
    Write-Host "  ✓ Favicon and logos updated" -ForegroundColor White
}
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "  2. Hard refresh (Ctrl+Shift+R)" -ForegroundColor White  
Write-Host "  3. Access: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "The tab should now show 'PSSHRM' instead of 'OrangeHRM'!" -ForegroundColor Green
Write-Host ""
