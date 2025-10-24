#!/bin/bash

echo "🎯 快速验证API测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_117ca14556c34271"
SUCCESS_COUNT=0
FAILURE_COUNT=0

echo "测试配置:"
echo "  - API地址: $API_BASE"
echo "  - API密钥: $API_KEY"
echo ""

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "[$(date '+%H:%M:%S')] 测试: $test_name"
    
    if eval "$test_command"; then
        echo "✅ $test_name - 成功"
        ((SUCCESS_COUNT++))
        return 0
    else
        echo "❌ $test_name - 失败"
        ((FAILURE_COUNT++))
        return 1
    fi
}

# 测试1: 健康检查
test_health() {
    curl -s "$API_BASE/api/health" | grep -q "ok"
}

# 测试2: 钱包列表
test_list_wallets() {
    curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" | grep -q "name"
}

# 测试3: 创建钱包
test_create_wallet() {
    local wallet_name="test_wallet_$(date +%s)"
    local response=$(curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"测试钱包\", \"quantum_safe\": false}")
    
    echo "创建钱包响应: $response"
    echo "$response" | grep -q "id\|name\|quantum_safe"
}

# 测试4: 余额查询
test_get_balance() {
    local wallet_name="test_wallet_$(date +%s)"
    # 先创建钱包
    curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"余额测试钱包\", \"quantum_safe\": false}" > /dev/null
    
    curl -s -X GET "$API_BASE/api/wallets/$wallet_name/balance?network=eth" \
        -H "Authorization: Bearer $API_KEY" | grep -q "balance"
}

# 测试5: 交易历史
test_transaction_history() {
    local wallet_name="test_wallet_$(date +%s)"
    # 先创建钱包
    curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"历史测试钱包\", \"quantum_safe\": false}" > /dev/null
    
    curl -s -X GET "$API_BASE/api/wallets/$wallet_name/history" \
        -H "Authorization: Bearer $API_KEY" | grep -q "transactions"
}

# 测试6: 网络状态
test_network_status() {
    curl -s -X GET "$API_BASE/api/metrics" \
        -H "Authorization: Bearer $API_KEY" | grep -q "defi_hot_wallet"
}

# 运行所有测试
run_test "健康检查" "test_health"
run_test "钱包列表" "test_list_wallets"
run_test "创建钱包" "test_create_wallet"
run_test "余额查询" "test_get_balance"
run_test "交易历史" "test_transaction_history"
run_test "网络状态" "test_network_status"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 测试结果:"
echo "  成功: $SUCCESS_COUNT"
echo "  失败: $FAILURE_COUNT"
echo "  成功率: $SUCCESS_COUNT/6"

if [ $SUCCESS_COUNT -eq 6 ]; then
    echo "🎉 所有测试通过！可以开始1周自动化测试了！"
    echo ""
    echo "下一步: 运行1周自动化测试"
    echo "命令: ./week_automated_test.sh"
else
    echo "⚠️ 还有 $FAILURE_COUNT 个测试失败，需要进一步调试"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
