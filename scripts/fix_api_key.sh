#!/bin/bash

echo "🔑 修复API密钥问题"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "问题: API认证失败 (AUTH_FAILED)"
echo "原因: 测试脚本使用的API密钥与服务器不匹配"
echo ""

echo "解决方案: 使用正确的API密钥重新测试"
echo ""

# 尝试不同的API密钥
API_KEYS=(
    "testnet_api_key_117ca14556c34271"
    "test_api_key"
    "testnet_api_key"
    ""
)

API_BASE="http://localhost:8888"

echo "测试不同的API密钥..."
echo ""

for api_key in "${API_KEYS[@]}"; do
    echo "测试API密钥: '$api_key'"
    
    if [ -z "$api_key" ]; then
        echo "测试无API密钥..."
        response=$(curl -s -X GET "$API_BASE/api/wallets")
    else
        response=$(curl -s -X GET "$API_BASE/api/wallets" -H "Authorization: Bearer $api_key")
    fi
    
    echo "响应: $response"
    
    if echo "$response" | grep -q "name\|\[\]"; then
        echo "✅ 找到正确的API密钥: '$api_key'"
        echo ""
        echo "请使用以下命令重新测试:"
        echo "export API_KEY='$api_key'"
        echo "./quick_test.sh"
        exit 0
    elif echo "$response" | grep -q "Unauthorized"; then
        echo "❌ API密钥 '$api_key' 无效"
    else
        echo "❓ API密钥 '$api_key' 响应异常"
    fi
    
    echo ""
done

echo "⚠️ 没有找到有效的API密钥"
echo "请检查服务器启动日志中的API密钥"
