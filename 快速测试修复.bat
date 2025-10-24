@echo off
echo 🚀 快速测试修复
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set API_BASE=http://localhost:8888
set API_KEY=testnet_api_key_117ca14556c34271

echo 1. 测试健康检查...
curl -s "%API_BASE%/api/health"
echo.
echo.

echo 2. 测试创建钱包（包含quantum_safe字段）...
set WALLET_NAME=test_wallet_%RANDOM%
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"测试钱包\", \"quantum_safe\": false}"
echo.
echo.

echo 3. 测试钱包列表...
curl -s -X GET "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo 4. 测试余额查询...
curl -s -X GET "%API_BASE%/api/wallets/%WALLET_NAME%/balance?network=eth" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo 5. 测试交易历史...
curl -s -X GET "%API_BASE%/api/wallets/%WALLET_NAME%/history" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo 6. 测试网络状态...
curl -s -X GET "%API_BASE%/api/metrics" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo ✅ 快速测试完成！
pause
