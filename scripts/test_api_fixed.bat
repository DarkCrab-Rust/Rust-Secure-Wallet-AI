@echo off
echo 🔧 测试修复后的API端点
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set API_BASE=http://localhost:8888
set API_KEY=testnet_api_key_117ca14556c34271

echo 测试配置:
echo   - API地址: %API_BASE%
echo   - API密钥: %API_KEY%
echo.

echo 开始测试修复后的API端点...
echo.

echo [%date% %time%] 运行测试: 健康检查
curl -s "%API_BASE%/api/health"
if %errorlevel% equ 0 (
    echo ✅ 健康检查 - 成功
) else (
    echo ❌ 健康检查 - 失败
)

echo.
echo [%date% %time%] 运行测试: 钱包列表
curl -s -X GET "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%"
if %errorlevel% equ 0 (
    echo ✅ 钱包列表 - 成功
) else (
    echo ❌ 钱包列表 - 失败
)

echo.
echo [%date% %time%] 运行测试: 创建钱包
set WALLET_NAME=test_wallet_%RANDOM%
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"自动化测试钱包\", \"quantum_safe\": false}"
if %errorlevel% equ 0 (
    echo ✅ 创建钱包 - 成功
) else (
    echo ❌ 创建钱包 - 失败
)

echo.
echo [%date% %time%] 运行测试: 网络状态
curl -s -X GET "%API_BASE%/api/metrics" -H "Authorization: Bearer %API_KEY%"
if %errorlevel% equ 0 (
    echo ✅ 网络状态 - 成功
) else (
    echo ❌ 网络状态 - 失败
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 测试完成！
pause
