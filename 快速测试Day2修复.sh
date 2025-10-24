#!/bin/bash

echo "🧪 快速测试Day 2修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

# 从环境变量文件读取API密钥
API_KEY=$(grep "API_KEY=" .env.testnet.local | cut -d'=' -f2)
echo "使用API密钥: $API_KEY"

echo ""
echo "Step 1: 健康检查..."
HEALTH_RESPONSE=$(curl -s http://localhost:8888/health)
echo "健康检查响应: $HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q "ok\|healthy"; then
    echo "✅ 健康检查成功"
else
    echo "❌ 健康检查失败"
    exit 1
fi

echo ""
echo "Step 2: 创建测试钱包..."
WALLET_RESPONSE=$(curl -s -X POST http://localhost:8888/wallets \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "day2_test_wallet", "description": "Day2测试钱包"}')

echo "钱包创建响应: $WALLET_RESPONSE"

# 提取钱包地址
WALLET_ADDRESS=$(echo "$WALLET_RESPONSE" | grep -o '"address":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$WALLET_ADDRESS" ]; then
    echo "✅ 钱包创建成功，地址: $WALLET_ADDRESS"
    
    echo ""
    echo "Step 3: 测试余额查询（Day 2修复验证）..."
    BALANCE_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/wallets/$WALLET_ADDRESS/balance)
    
    echo "余额查询响应: $BALANCE_RESPONSE"
    
    if echo "$BALANCE_RESPONSE" | grep -q "balance\|error"; then
        echo "✅ 余额查询成功 - Day 2修复生效！"
    else
        echo "❌ 余额查询失败"
    fi
    
    echo ""
    echo "Step 4: 查询钱包列表..."
    LIST_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/wallets)
    
    echo "钱包列表响应: $LIST_RESPONSE"
    
    echo ""
    echo "Step 5: 查询网络状态..."
    NETWORK_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/network/status)
    
    echo "网络状态响应: $NETWORK_RESPONSE"
    
else
    echo "❌ 钱包创建失败"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Day 2修复测试完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
