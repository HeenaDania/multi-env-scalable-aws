# PowerShell script to setup Jenkins on Windows

# Start Jenkins service
Write-Host "Starting Jenkins service..." -ForegroundColor Green
Start-Service Jenkins

# Wait for Jenkins to start
Start-Sleep -Seconds 30

# Open Jenkins in browser
Start-Process "http://localhost:8080"

Write-Host "Jenkins is starting up..." -ForegroundColor Green
Write-Host "Please follow these steps:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:8080 in your browser" -ForegroundColor White
Write-Host "2. Get the initial admin password from: C:\Program Files\Jenkins\secrets\initialAdminPassword" -ForegroundColor White
Write-Host "3. Install suggested plugins" -ForegroundColor White
Write-Host "4. Create an admin user" -ForegroundColor White
Write-Host "5. Install additional plugins: Terraform, AWS Pipeline, Pipeline" -ForegroundColor White

# Get initial admin password
$initialPassword = Get-Content "C:\Program Files\Jenkins\secrets\initialAdminPassword"
Write-Host "Initial Admin Password: $initialPassword" -ForegroundColor Cyan
