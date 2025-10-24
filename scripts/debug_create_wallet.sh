#!/bin/bash

echo "🔍 调试创建钱包问题"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_117ca14556c34271"
WALLET_NAME="debug_wallet_$(date +%s)"

echo "测试配置:"
echo "  - API地址: $API_BASE"
echo "  - API密钥: $API_KEY"
echo "  - 钱包名称: $WALLET_NAME"
echo ""

echo "1. 测试创建钱包请求..."
echo "请求数据: {\"name\": \"$WALLET_NAME\", \"description\": \"调试钱包\", \"quantum_safe\": false}"
echo ""

echo "响应内容:"
response=$(curl -s -X POST "$API_BASE/api/wallets" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$WALLET_NAME\", \"description\": \"调试钱包\", \"quantum_safe\": false}")

echo "$response"
echo ""

echo "2. 检查响应内容..."
if echo "$response" | grep -q "address"; then
    echo "✅ 响应包含 'address' 字段"
else
    echo "❌ 响应不包含 'address' 字段"
fi

if echo "$response" | grep -q "error"; then
    echo "❌ 响应包含错误信息"
else
    echo "✅ 响应不包含错误信息"
fi

echo ""
echo "3. 检查HTTP状态码..."
status_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API_BASE/api/wallets" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$WALLET_NAME\", \"description\": \"调试钱包\", \"quantum_safe\": false}")

echo "HTTP状态码: $status_code"

if [ "$status_code" = "200" ]; then
    echo "✅ HTTP状态码正常"
else
    echo "❌ HTTP状态码异常: $status_code"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "调试完成！"
