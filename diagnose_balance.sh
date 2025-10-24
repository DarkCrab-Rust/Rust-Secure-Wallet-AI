#!/bin/bash

echo "🔍 诊断余额查询问题..."
echo ""

source .env.testnet.local

API_URL="http://localhost:8888"

# ============================================
# 1. 测试不同网络
# ============================================

echo "📋 测试 1: 尝试不同网络"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for network in eth sepolia polygon bsc solana solana-devnet; do
  echo "网络: $network"
  curl -s -X GET "$API_URL/api/wallets/test_wallet_1/balance?network=$network" \
    -H "Authorization: $API_KEY"
  echo -e "\n"
  sleep 1
done

# ============================================
# 2. 检查钱包详情
# ============================================

echo ""
echo "📋 测试 2: 检查钱包列表（获取完整信息）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -s -X GET "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY"
echo -e "\n"

# ============================================
# 3. 测试API健康（确认服务正常）
# ============================================

echo ""
echo "📋 测试 3: API健康检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -s -X GET "$API_URL/api/health"
echo -e "\n"

# ============================================
# 4. 创建新钱包并立即查询余额
# ============================================

echo ""
echo "📋 测试 4: 创建新钱包并查询余额"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

WALLET_NAME="diagnostic_wallet_$(date +%s)"

echo "创建钱包: $WALLET_NAME"
CREATE_RESULT=$(curl -s -X POST "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$WALLET_NAME\", \"quantum_safe\": false}")

echo "$CREATE_RESULT"
echo ""

sleep 2

echo "查询余额 (sepolia):"
curl -s -X GET "$API_URL/api/wallets/$WALLET_NAME/balance?network=sepolia" \
  -H "Authorization: $API_KEY"
echo -e "\n"

# ============================================
# 总结
# ============================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 诊断完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "请查看上面的输出，特别注意:"
echo "1. 不同网络的余额查询结果"
echo "2. 钱包列表中是否有地址信息"
echo "3. 新创建的钱包是否能查询余额"
echo ""
echo "如果所有网络都失败，请查看服务器日志（终端1）"

