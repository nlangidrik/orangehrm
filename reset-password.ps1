# Password Reset Script for OrangeHRM
# Usage: .\reset-password.ps1 -Username "pssadmin" -NewPassword "YourNewPassword123!"

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$true)]
    [string]$NewPassword
)

Write-Host "Resetting password for user: $Username" -ForegroundColor Cyan

# Generate password hash with cost 12 (OrangeHRM standard)
Write-Host "Generating password hash..." -ForegroundColor Yellow
$hash = docker exec orangehrm_app php -r "echo password_hash('$NewPassword', PASSWORD_BCRYPT, ['cost' => 12]);"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error generating password hash!" -ForegroundColor Red
    exit 1
}

# Update password in database
Write-Host "Updating password in database..." -ForegroundColor Yellow
$sql = "UPDATE ohrm_user SET user_password = '$hash' WHERE user_name = '$Username';"
docker exec -i orangehrm_mysql mysql -u orangehrm -pstubbies-sip-iff-unfrocking orangehrm_mysql -e $sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Password reset successfully!" -ForegroundColor Green
    Write-Host "Username: $Username" -ForegroundColor White
    Write-Host "New password: $NewPassword" -ForegroundColor White
} else {
    Write-Host "`n✗ Error updating password!" -ForegroundColor Red
    exit 1
}

