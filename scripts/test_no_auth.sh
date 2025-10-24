#!/bin/bash

echo "🔓 测试无认证API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

API_BASE="http://localhost:8888"

echo "测试配置:"
echo "  - API地址: $API_BASE"
echo "  - 认证: 无 (测试服务器是否允许无认证访问)"
echo ""

# 测试1: 健康检查 (应该不需要认证)
echo "1. 测试健康检查 (无认证)..."
response=$(curl -s "$API_BASE/api/health")
echo "响应: $response"
if echo "$response" | grep -q "ok"; then
    echo "✅ 健康检查 - 成功"
else
    echo "❌ 健康检查 - 失败"
fi
echo ""

# 测试2: 钱包列表 (无认证)
echo "2. 测试钱包列表 (无认证)..."
response=$(curl -s -X GET "$API_BASE/api/wallets")
echo "响应: $response"
if echo "$response" | grep -q "name\|\[\]"; then
    echo "✅ 钱包列表 - 成功 (无认证)"
else
    echo "❌ 钱包列表 - 失败 (需要认证)"
fi
echo ""

# 测试3: 创建钱包 (无认证)
echo "3. 测试创建钱包 (无认证)..."
wallet_name="test_wallet_$(date +%s)"
response=$(curl -s -X POST "$API_BASE/api/wallets" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$wallet_name\", \"description\": \"测试钱包\", \"quantum_safe\": false}")
echo "响应: $response"
if echo "$response" | grep -q "id\|name\|quantum_safe"; then
    echo "✅ 创建钱包 - 成功 (无认证)"
else
    echo "❌ 创建钱包 - 失败 (需要认证)"
fi
echo ""

# 测试4: 网络状态 (无认证)
echo "4. 测试网络状态 (无认证)..."
response=$(curl -s -X GET "$API_BASE/api/metrics")
echo "响应: $response"
if echo "$response" | grep -q "defi_hot_wallet"; then
    echo "✅ 网络状态 - 成功 (无认证)"
else
    echo "❌ 网络状态 - 失败 (需要认证)"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试完成！"
echo ""
echo "如果所有测试都失败，说明服务器需要API认证"
echo "请检查服务器启动日志中的API密钥"
