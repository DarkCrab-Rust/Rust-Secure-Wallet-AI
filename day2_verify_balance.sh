#!/bin/bash

echo "✅ Day 2: 验证余额查询修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

source .env.testnet.local

API_URL="http://localhost:8888"

# ============================================
# 1. 创建新钱包
# ============================================

echo "📋 测试 1: 创建新钱包"
WALLET_NAME="day2_test_wallet"

CREATE_RESULT=$(curl -s -X POST "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$WALLET_NAME\", \"quantum_safe\": false}")

echo "$CREATE_RESULT"
echo ""

# ============================================
# 2. 测试所有网络的余额查询
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 测试 2: 余额查询 (所有网络)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for network in eth sepolia polygon bsc solana solana-devnet; do
  echo "🔍 网络: $network"
  BALANCE_RESULT=$(curl -s -X GET "$API_URL/api/wallets/$WALLET_NAME/balance?network=$network" \
    -H "Authorization: $API_KEY" \
    -H "Content-Type: application/json")
  
  echo "$BALANCE_RESULT"
  
  # 检查是否成功
  if echo "$BALANCE_RESULT" | grep -q "balance"; then
    echo "  ✅ 成功！"
  elif echo "$BALANCE_RESULT" | grep -q "error"; then
    echo "  ❌ 失败"
  fi
  echo ""
  sleep 1
done

# ============================================
# 3. 查看服务器日志提示
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 测试 3: 服务器日志"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "请查看终端1（服务器）的日志输出，应该看到:"
echo "  ✅ 'Loaded network config: sepolia (RPC: ...)'"
echo "  ✅ 'Initializing client for network: sepolia'"
echo "  ✅ 'Connected to sepolia (Chain ID: 11155111)'"
echo ""

# ============================================
# 总结
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Day 2 测试总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "如果所有网络都返回余额（即使是0），说明修复成功！"
echo ""
echo "下一步:"
echo "1. 从水龙头获取测试币"
echo "2. 发送真实交易"
echo "3. 验证交易历史"
echo ""

