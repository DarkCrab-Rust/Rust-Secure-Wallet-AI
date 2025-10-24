@echo off
echo 手动启动测试网测试
echo.

cd /d "%~dp0"

echo Step 1: 停止旧进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    echo 停止进程 %%a
    taskkill /F /PID %%a >nul 2>&1
)

echo Step 2: 编译项目...
cargo build --release
if %errorlevel% neq 0 (
    echo 编译失败
    pause
    exit /b 1
)

echo Step 3: 启动服务器...
start "Testnet Server" cmd /c "start_testnet.sh"

echo 等待服务器启动...
timeout /t 15 /nobreak >nul

echo Step 4: 测试API...
curl -s http://localhost:8080/health
echo.

echo Step 5: 创建测试钱包...
curl -X POST http://localhost:8080/wallets -H "Authorization: Bearer test-api-key-12345" -H "Content-Type: application/json" -d "{\"name\": \"test_wallet_1\", \"description\": \"测试钱包1\"}"
echo.

echo Step 6: 查询钱包列表...
curl -s -H "Authorization: Bearer test-api-key-12345" http://localhost:8080/wallets
echo.

echo 测试完成！
pause
