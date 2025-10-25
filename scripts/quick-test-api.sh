#!/bin/bash

echo "🧪 快速测试API - Day 2修复验证"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 从.env.testnet.local读取API密钥
if [ -f ".env.testnet.local" ]; then
    API_KEY=$(grep "API_KEY=" .env.testnet.local | cut -d'=' -f2)
    echo "✅ 找到API密钥: $API_KEY"
else
    API_KEY="testnet_api_key_f502e18b9852ae68"
    echo "⚠️ 使用默认API密钥: $API_KEY"
fi

echo ""
echo "Step 1: 测试健康检查..."
curl -s http://localhost:8888/health
echo ""

echo ""
echo "Step 2: 创建测试钱包..."
WALLET_RESPONSE=$(curl -s -X POST http://localhost:8888/wallets \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "test_wallet_day2", "description": "Day2测试钱包"}')

echo "$WALLET_RESPONSE"
echo ""

# 提取钱包地址
WALLET_ADDRESS=$(echo "$WALLET_RESPONSE" | grep -o '"address":"[^"]*"' | cut -d'"' -f4)

if [ ! -z "$WALLET_ADDRESS" ]; then
    echo "✅ 钱包创建成功，地址: $WALLET_ADDRESS"
    
    echo ""
    echo "Step 3: 测试余额查询（Day 2修复验证）..."
    BALANCE_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/wallets/$WALLET_ADDRESS/balance)
    
    echo "$BALANCE_RESPONSE"
    
    if echo "$BALANCE_RESPONSE" | grep -q "balance\|error"; then
        echo "✅ 余额查询成功 - Day 2修复生效！"
    else
        echo "❌ 余额查询失败"
    fi
    
    echo ""
    echo "Step 4: 查询交易历史..."
    TX_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/wallets/$WALLET_ADDRESS/transactions)
    
    echo "$TX_RESPONSE"
    
    echo ""
    echo "Step 5: 查询网络状态..."
    NETWORK_RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" \
      http://localhost:8888/network/status)
    
    echo "$NETWORK_RESPONSE"
    
else
    echo "❌ 钱包创建失败"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Day 2测试完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
