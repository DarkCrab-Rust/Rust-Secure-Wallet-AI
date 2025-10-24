#!/bin/bash

# 测试网API测试脚本
# 在启动服务器后运行

# ============================================
# 从环境文件读取API密钥
# ============================================

if [ -f .env.testnet.local ]; then
    source .env.testnet.local
    echo "✅ 已加载环境变量"
else
    echo "❌ 错误: 找不到 .env.testnet.local"
    echo "请先运行 ./start_testnet.sh 启动服务器"
    exit 1
fi

API_URL="http://localhost:8888"

echo "🚀 开始测试钱包API..."
echo "API地址: $API_URL"
echo "API密钥: $API_KEY"
echo ""

# ============================================
# 1. 健康检查 (无需认证)
# ============================================

echo "📋 测试 1: 健康检查"
curl -s -X GET "$API_URL/api/health" | jq '.' 2>/dev/null || curl -X GET "$API_URL/api/health"
echo -e "\n"
sleep 1

# ============================================
# 2. 创建钱包
# ============================================

echo "📋 测试 2: 创建钱包"
curl -s -X POST "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test_wallet_1",
    "quantum_safe": false
  }' | jq '.' 2>/dev/null || curl -X POST "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "test_wallet_1", "quantum_safe": false}'
echo -e "\n"
sleep 1

# ============================================
# 3. 列出所有钱包
# ============================================

echo "📋 测试 3: 列出所有钱包"
curl -s -X GET "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" | jq '.' 2>/dev/null || curl -X GET "$API_URL/api/wallets" \
  -H "Authorization: $API_KEY"
echo -e "\n"
sleep 1

# ============================================
# 4. 查询余额 (Sepolia测试网)
# ============================================

echo "📋 测试 4: 查询余额 (Sepolia测试网)"
curl -s -X GET "$API_URL/api/wallets/test_wallet_1/balance?network=sepolia" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" | jq '.' 2>/dev/null || curl -X GET "$API_URL/api/wallets/test_wallet_1/balance?network=sepolia" \
  -H "Authorization: $API_KEY"
echo -e "\n"
sleep 1

# ============================================
# 5. 备份钱包
# ============================================

echo "📋 测试 5: 备份钱包 (获取助记词)"
BACKUP_RESPONSE=$(curl -s -X GET "$API_URL/api/wallets/test_wallet_1/backup" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json")

echo "$BACKUP_RESPONSE" | jq '.' 2>/dev/null || echo "$BACKUP_RESPONSE"

# 保存助记词
SEED_PHRASE=$(echo "$BACKUP_RESPONSE" | jq -r '.seed_phrase' 2>/dev/null)
if [ "$SEED_PHRASE" != "null" ] && [ -n "$SEED_PHRASE" ]; then
    echo ""
    echo "⚠️  重要: 助记词已保存到 backup_seed.txt"
    echo "$SEED_PHRASE" > backup_seed.txt
fi
echo -e "\n"
sleep 1

# ============================================
# 6. 查询交易历史
# ============================================

echo "📋 测试 6: 查询交易历史"
curl -s -X GET "$API_URL/api/wallets/test_wallet_1/history" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" | jq '.' 2>/dev/null || curl -X GET "$API_URL/api/wallets/test_wallet_1/history" \
  -H "Authorization: $API_KEY"
echo -e "\n"
sleep 1

# ============================================
# 7. 查看系统指标
# ============================================

echo "📋 测试 7: 查看系统指标"
curl -s -X GET "$API_URL/api/metrics" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" | jq '.' 2>/dev/null || curl -X GET "$API_URL/api/metrics" \
  -H "Authorization: $API_KEY"
echo -e "\n"

# ============================================
# 总结
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 基础API测试完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "下一步:"
echo "1. 从水龙头获取测试币: https://sepoliafaucet.com/"
echo "2. 获取钱包地址: 查看上面的'列出所有钱包'输出"
echo "3. 等待10分钟后查询余额"
echo "4. 尝试发送测试交易"
echo ""
echo "详细计划请查看: 测试网1周测试计划.md"

