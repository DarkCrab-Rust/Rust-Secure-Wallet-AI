@echo off
chcp 65001 >nul
echo 🔧 解决端口冲突问题
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd /d "%~dp0"

echo Step 1: 查找占用8888端口的进程...
netstat -ano | findstr :8888

echo.
echo Step 2: 停止占用端口的进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8888') do (
    echo 停止进程 %%a
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo Step 3: 等待端口释放...
timeout /t 3 /nobreak >nul

echo.
echo Step 4: 重新启动测试网...
echo 请在Git Bash中运行: ./start_testnet.sh

echo.
echo 或者直接运行:
echo cargo run --bin hot_wallet

pause
