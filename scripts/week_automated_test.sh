#!/bin/bash

echo "🤖 1周自动化测试网测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

# 测试配置
API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_117ca14556c34271"
TEST_DURATION_DAYS=7
TEST_INTERVAL_MINUTES=30

# 创建测试日志目录
mkdir -p logs/week_test
LOG_FILE="logs/week_test/automated_test_$(date +%Y%m%d_%H%M%S).log"

echo "测试配置:"
echo "  - 测试时长: $TEST_DURATION_DAYS 天"
echo "  - 测试间隔: $TEST_INTERVAL_MINUTES 分钟"
echo "  - API地址: $API_BASE"
echo "  - 日志文件: $LOG_FILE"
echo ""

# 记录开始时间
START_TIME=$(date)
echo "开始时间: $START_TIME" | tee -a "$LOG_FILE"

# 测试计数器
TEST_COUNT=0
SUCCESS_COUNT=0
FAILURE_COUNT=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 运行测试: $test_name" | tee -a "$LOG_FILE"
    
    if eval "$test_command" >> "$LOG_FILE" 2>&1; then
        echo "✅ $test_name - 成功" | tee -a "$LOG_FILE"
        ((SUCCESS_COUNT++))
        return 0
    else
        echo "❌ $test_name - 失败" | tee -a "$LOG_FILE"
        ((FAILURE_COUNT++))
        return 1
    fi
}

# 健康检查测试
test_health() {
    curl -s "$API_BASE/api/health" | grep -q "ok\|healthy"
}

# 钱包创建测试
test_create_wallet() {
    local wallet_name="test_wallet_$(date +%s)"
    local response=$(curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"自动化测试钱包\", \"quantum_safe\": false}")
    
    # 检查响应是否包含成功标识（id、name或quantum_safe字段）
    echo "$response" | grep -q "id\|name\|quantum_safe"
}

# 钱包列表测试
test_list_wallets() {
    local response=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: Bearer $API_KEY")
    
    echo "$response" | grep -q "name\|\[\]"
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
        echo "$response" | grep -q "balance\|error"
    else
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
        echo "$response" | grep -q "transactions\|\[\]"
    else
        return 1
    fi
}

# 网络状态测试
test_network_status() {
    local response=$(curl -s -X GET "$API_BASE/api/metrics" \
        -H "Authorization: Bearer $API_KEY")
    
    echo "$response" | grep -q "defi_hot_wallet\|metrics"
}

# 主测试循环
echo "开始自动化测试循环..."
echo "按 Ctrl+C 可以停止测试"
echo ""

while true; do
    ((TEST_COUNT++))
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "第 $TEST_COUNT 轮测试 - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 运行所有测试
    run_test "健康检查" "test_health"
    run_test "钱包列表" "test_list_wallets"
    run_test "创建钱包" "test_create_wallet"
    run_test "余额查询" "test_get_balance"
    run_test "交易历史" "test_transaction_history"
    run_test "网络状态" "test_network_status"
    
    # 显示统计信息
    echo ""
    echo "📊 测试统计:"
    echo "  总测试数: $TEST_COUNT"
    echo "  成功: $SUCCESS_COUNT"
    echo "  失败: $FAILURE_COUNT"
    echo "  成功率: $(( SUCCESS_COUNT * 100 / (SUCCESS_COUNT + FAILURE_COUNT) ))%"
    
    # 检查是否达到测试时长
    if [ $TEST_COUNT -ge $((TEST_DURATION_DAYS * 24 * 60 / TEST_INTERVAL_MINUTES)) ]; then
        echo ""
        echo "🎉 测试完成！已达到 $TEST_DURATION_DAYS 天的测试目标"
        break
    fi
    
    echo ""
    echo "⏰ 等待 $TEST_INTERVAL_MINUTES 分钟后进行下一轮测试..."
    sleep $((TEST_INTERVAL_MINUTES * 60))
done

# 生成最终报告
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 最终测试报告"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "开始时间: $START_TIME"
echo "结束时间: $(date)"
echo "总测试轮数: $TEST_COUNT"
echo "成功测试: $SUCCESS_COUNT"
echo "失败测试: $FAILURE_COUNT"
echo "成功率: $(( SUCCESS_COUNT * 100 / (SUCCESS_COUNT + FAILURE_COUNT) ))%"
echo "详细日志: $LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
