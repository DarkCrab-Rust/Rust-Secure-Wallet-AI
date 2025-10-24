@echo off
echo 🔧 修复环境变量问题
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

echo 问题诊断:
echo   - 创建钱包失败是因为 WALLET_ENC_KEY 环境变量未设置
echo   - 服务器需要这个密钥来加密钱包数据
echo.

echo 解决方案:
echo   1. 使用 start_testnet.sh 启动服务器 (推荐)
echo   2. 或者手动设置环境变量
echo.

echo 方法1: 使用正确的启动脚本
echo   ./start_testnet.sh
echo.

echo 方法2: 手动设置环境变量
echo   set WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
echo   set API_KEY=testnet_api_key_117ca14556c34271
echo   cargo run --bin hot_wallet
echo.

echo 现在设置环境变量并启动服务器...
echo.

REM 设置环境变量
set WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
set API_KEY=testnet_api_key_117ca14556c34271
set CORS_ALLOW_ORIGIN=http://localhost:3000
set DATABASE_URL=sqlite://./data/testnet_wallet.db?mode=rwc
set RUST_LOG=info
set SERVER_HOST=127.0.0.1
set SERVER_PORT=8888

echo ✅ 环境变量已设置
echo.

echo 🚀 启动服务器...
cargo run --bin hot_wallet
