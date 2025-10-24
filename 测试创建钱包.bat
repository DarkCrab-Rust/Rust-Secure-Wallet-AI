@echo off
echo 🔍 测试创建钱包
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set API_BASE=http://localhost:8888
set API_KEY=testnet_api_key_117ca14556c34271
set WALLET_NAME=test_wallet_%RANDOM%

echo 测试配置:
echo   - API地址: %API_BASE%
echo   - API密钥: %API_KEY%
echo   - 钱包名称: %WALLET_NAME%
echo.

echo 1. 发送创建钱包请求...
echo 请求数据: {"name": "%WALLET_NAME%", "description": "测试钱包", "quantum_safe": false}
echo.

echo 2. 响应内容:
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"测试钱包\", \"quantum_safe\": false}"
echo.
echo.

echo 3. 检查响应内容...
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"测试钱包\", \"quantum_safe\": false}" | findstr /C:"address" >nul
if %errorlevel% equ 0 (
    echo ✅ 响应包含 'address' 字段
) else (
    echo ❌ 响应不包含 'address' 字段
)

curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"测试钱包\", \"quantum_safe\": false}" | findstr /C:"id" >nul
if %errorlevel% equ 0 (
    echo ✅ 响应包含 'id' 字段
) else (
    echo ❌ 响应不包含 'id' 字段
)

curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"测试钱包\", \"quantum_safe\": false}" | findstr /C:"name" >nul
if %errorlevel% equ 0 (
    echo ✅ 响应包含 'name' 字段
) else (
    echo ❌ 响应不包含 'name' 字段
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 测试完成！
pause
