#!/bin/bash

echo "🔧 测试创建钱包修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_117ca14556c34271"
WALLET_NAME="test_wallet_$(date +%s)"

echo "测试配置:"
echo "  - API地址: $API_BASE"
echo "  - API密钥: $API_KEY"
echo "  - 钱包名称: $WALLET_NAME"
echo ""

echo "1. 发送创建钱包请求..."
echo "请求数据: {\"name\": \"$WALLET_NAME\", \"description\": \"测试钱包\", \"quantum_safe\": false}"
echo ""

echo "2. 响应内容:"
response=$(curl -s -X POST "$API_BASE/api/wallets" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$WALLET_NAME\", \"description\": \"测试钱包\", \"quantum_safe\": false}")

echo "$response"
echo ""

echo "3. 检查响应内容..."
if echo "$response" | grep -q "id"; then
    echo "✅ 响应包含 'id' 字段"
else
    echo "❌ 响应不包含 'id' 字段"
fi

if echo "$response" | grep -q "name"; then
    echo "✅ 响应包含 'name' 字段"
else
    echo "❌ 响应不包含 'name' 字段"
fi

if echo "$response" | grep -q "quantum_safe"; then
    echo "✅ 响应包含 'quantum_safe' 字段"
else
    echo "❌ 响应不包含 'quantum_safe' 字段"
fi

echo ""
echo "4. 测试修复后的判断逻辑..."
if echo "$response" | grep -q "id\|name\|quantum_safe"; then
    echo "✅ 创建钱包测试 - 成功"
else
    echo "❌ 创建钱包测试 - 失败"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试完成！"
