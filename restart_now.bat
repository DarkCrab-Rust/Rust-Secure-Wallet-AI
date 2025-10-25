@echo off
echo ========================================
echo Restarting Server with CORS 3000+3010
echo ========================================
echo.

cd /d "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

REM Kill existing server
echo Stopping existing server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8888') do (
    taskkill /F /PID %%a 2>nul
)

timeout /t 2 /nobreak >nul

REM Start server with new CORS config
echo Starting server...
"C:\Program Files\Git\bin\bash.exe" --login -i -c "cd 'C:/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet' && bash restart_server.sh"

echo.
echo Done!
pause

