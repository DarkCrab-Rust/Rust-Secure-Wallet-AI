#!/bin/bash

# 测试网API手动测试脚本
# 无需前端，直接测试后端功能

# ============================================
# 配置
# ============================================

API_URL="http://localhost:8888"
API_KEY="testnet_api_key_change_in_production"

echo "🚀 开始测试钱包API..."
echo "API地址: $API_URL"
echo ""

# ============================================
# 1. 健康检查 (无需认证)
# ============================================

echo "📋 测试 1: 健康检查"
curl -X GET "$API_URL/api/health" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 2. 创建钱包
# ============================================

echo "📋 测试 2: 创建钱包"
curl -X POST "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test_wallet_1",
    "quantum_safe": false
  }'
echo -e "\n"

# ============================================
# 3. 列出所有钱包
# ============================================

echo "📋 测试 3: 列出所有钱包"
curl -X GET "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 4. 查询余额 (Sepolia测试网)
# ============================================

echo "📋 测试 4: 查询余额"
curl -X GET "$API_URL/api/wallets/test_wallet_1/balance?network=sepolia" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 5. 备份钱包
# ============================================

echo "📋 测试 5: 备份钱包"
curl -X GET "$API_URL/api/wallets/test_wallet_1/backup" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 6. 查询交易历史
# ============================================

echo "📋 测试 6: 查询交易历史"
curl -X GET "$API_URL/api/wallets/test_wallet_1/history" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 7. 发送交易 (需要先获取测试币)
# ============================================

echo "📋 测试 7: 发送交易 (如果有余额)"
echo "注意: 需要先从水龙头获取测试币!"
curl -X POST "$API_URL/api/wallets/test_wallet_1/send" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "amount": "0.001",
    "network": "sepolia"
  }'
echo -e "\n"

# ============================================
# 8. 查看指标
# ============================================

echo "📋 测试 8: 查看系统指标"
curl -X GET "$API_URL/api/metrics" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

# ============================================
# 9. 删除钱包
# ============================================

echo "📋 测试 9: 删除钱包"
curl -X DELETE "$API_URL/api/wallets/test_wallet_1" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json"
echo -e "\n"

echo "✅ 所有API测试完成！"

