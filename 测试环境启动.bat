@echo off
chcp 65001 >nul
echo 🧪 测试环境启动服务器
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
echo Step 3: 设置测试环境变量...
set WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
set API_KEY=testnet_api_key_117ca14556c34271
set CORS_ALLOW_ORIGIN=http://localhost:3000
set DATABASE_URL=sqlite://./data/testnet_wallet.db?mode=rwc
set RUST_LOG=info
set SERVER_HOST=127.0.0.1
set SERVER_PORT=8888
set TEST_SKIP_DECRYPT=1
set ALLOW_BRIDGE_MOCKS=1

echo ✅ 测试环境变量已设置
echo.

echo Step 4: 启动服务器 (测试模式)...
cargo run --bin hot_wallet
