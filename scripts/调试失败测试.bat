@echo off
echo 🔍 调试失败的测试
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set API_BASE=http://localhost:8888
set API_KEY=testnet_api_key_117ca14556c34271

echo 1. 测试钱包列表（失败的原因）...
echo 请求: GET %API_BASE%/api/wallets
echo 响应:
curl -s -X GET "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo 2. 测试创建钱包（失败的原因）...
set WALLET_NAME=debug_wallet_%RANDOM%
echo 请求: POST %API_BASE%/api/wallets
echo 数据: {"name": "%WALLET_NAME%", "description": "调试钱包", "quantum_safe": false}
echo 响应:
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"调试钱包\", \"quantum_safe\": false}"
echo.
echo.

echo 3. 测试网络状态（失败的原因）...
echo 请求: GET %API_BASE%/api/metrics
echo 响应:
curl -s -X GET "%API_BASE%/api/metrics" -H "Authorization: Bearer %API_KEY%"
echo.
echo.

echo ✅ 调试完成！
pause
