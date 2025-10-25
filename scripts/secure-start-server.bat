@echo off
chcp 65001 >nul
echo 🔐 安全启动服务器
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd /d "%~dp0"

echo Step 1: 终止占用端口的进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8888') do (
    echo 停止进程 %%a
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo Step 2: 等待端口释放...
timeout /t 3 /nobreak >nul

echo.
echo Step 3: 生成安全的WALLET_ENC_KEY...
REM 生成32字节随机密钥并base64编码
for /f %%i in ('powershell -command "[System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))"') do set WALLET_ENC_KEY=%%i

echo ✅ 安全密钥已生成

echo.
echo Step 4: 设置环境变量...
set API_KEY=testnet_api_key_117ca14556c34271
set CORS_ALLOW_ORIGIN=http://localhost:3000
set DATABASE_URL=sqlite://./data/testnet_wallet.db?mode=rwc
set RUST_LOG=info
set SERVER_HOST=127.0.0.1
set SERVER_PORT=8888

echo ✅ 环境变量已设置
echo.

echo Step 5: 启动服务器...
cargo run --bin hot_wallet
