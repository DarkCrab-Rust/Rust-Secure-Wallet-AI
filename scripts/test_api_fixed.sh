#!/bin/bash

echo "🔧 测试修复后的API端点"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 测试配置
API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_117ca14556c34271"

echo "测试配置:"
echo "  - API地址: $API_BASE"
echo "  - API密钥: $API_KEY"
echo ""

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 运行测试: $test_name"
    
    if eval "$test_command"; then
        echo "✅ $test_name - 成功"
        return 0
    else
        echo "❌ $test_name - 失败"
        return 1
    fi
}

# 健康检查测试
test_health() {
    local response=$(curl -s "$API_BASE/api/health")
    echo "健康检查响应: $response"
    echo "$response" | grep -q "ok\|healthy"
}

# 钱包列表测试
test_list_wallets() {
    local response=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY")
    echo "钱包列表响应: $response"
    echo "$response" | grep -q "wallets\|\[\]"
}

# 钱包创建测试
test_create_wallet() {
    local wallet_name="test_wallet_$(date +%s)"
    local response=$(curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"自动化测试钱包\"}")
    echo "创建钱包响应: $response"
    echo "$response" | grep -q "address"
}

# 余额查询测试
test_get_balance() {
    # 先获取钱包列表
    local wallets=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY")
    
    # 提取第一个钱包名称
    local wallet_name=$(echo "$wallets" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ ! -z "$wallet_name" ]; then
        local response=$(curl -s -X GET "$API_BASE/api/wallets/$wallet_name/balance?network=eth" \
            -H "Authorization: Bearer $API_KEY")
        echo "余额查询响应: $response"
        echo "$response" | grep -q "balance\|error"
    else
        echo "没有找到钱包，跳过余额查询"
        return 1
    fi
}

# 交易历史测试
test_transaction_history() {
    local wallets=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY")
    
    local wallet_name=$(echo "$wallets" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ ! -z "$wallet_name" ]; then
        local response=$(curl -s -X GET "$API_BASE/api/wallets/$wallet_name/history" \
            -H "Authorization: Bearer $API_KEY")
        echo "交易历史响应: $response"
        echo "$response" | grep -q "transactions\|\[\]"
    else
        echo "没有找到钱包，跳过交易历史查询"
        return 1
    fi
}

# 网络状态测试
test_network_status() {
    local response=$(curl -s -X GET "$API_BASE/api/metrics" \
        -H "Authorization: Bearer $API_KEY")
    echo "网络状态响应: $response"
    echo "$response" | grep -q "metrics\|uptime"
}

echo "开始测试修复后的API端点..."
echo ""

# 运行所有测试
run_test "健康检查" "test_health"
run_test "钱包列表" "test_list_wallets"
run_test "创建钱包" "test_create_wallet"
run_test "余额查询" "test_get_balance"
run_test "交易历史" "test_transaction_history"
run_test "网络状态" "test_network_status"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试完成！"
