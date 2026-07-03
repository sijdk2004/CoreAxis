Write-Host "Starting Backend..."
Start-Process -FilePath ".\backend\main.exe" -WorkingDirectory ".\backend"

Write-Host "Starting Frontend on port 5191..."
C:\Users\DELL\flutter\bin\flutter.bat run -d web-server --web-port 5191
