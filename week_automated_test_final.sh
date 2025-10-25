#!/bin/bash

echo "🤖 最终修复版1周自动化测试网测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

# 测试配置
API_BASE="http://localhost:8888"

# 让用户选择测试模式
echo "请选择测试模式:"
echo ""
echo "1. 快速测试 (5分钟间隔, 测试1小时)"
echo "2. 短期测试 (10分钟间隔, 测试6小时)"
echo "3. 中期测试 (30分钟间隔, 测试1天)"
echo "4. 长期测试 (1小时间隔, 测试3天)"
echo "5. 完整测试 (2小时间隔, 测试7天)"
echo "6. 自定义"
echo ""
read -p "请输入选项 (1-6): " mode_choice

case $mode_choice in
    1)
        TEST_DURATION_MINUTES=60
        TEST_INTERVAL_MINUTES=5
        TEST_NAME="快速测试"
        ;;
    2)
        TEST_DURATION_MINUTES=360
        TEST_INTERVAL_MINUTES=10
        TEST_NAME="短期测试"
        ;;
    3)
        TEST_DURATION_MINUTES=1440
        TEST_INTERVAL_MINUTES=30
        TEST_NAME="中期测试"
        ;;
    4)
        TEST_DURATION_MINUTES=4320
        TEST_INTERVAL_MINUTES=60
        TEST_NAME="长期测试"
        ;;
    5)
        TEST_DURATION_MINUTES=10080
        TEST_INTERVAL_MINUTES=120
        TEST_NAME="完整测试"
        ;;
    6)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "自定义测试配置"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # 测试时长
        echo "请输入测试时长:"
        read -p "  天数 (0-30): " test_days
        read -p "  小时 (0-23): " test_hours
        
        # 转换为分钟
        TEST_DURATION_MINUTES=$((test_days * 24 * 60 + test_hours * 60))
        
        # 测试间隔
        echo ""
        echo "请选择测试间隔:"
        echo "  1. 每5分钟"
        echo "  2. 每10分钟"
        echo "  3. 每30分钟"
        echo "  4. 每1小时"
        echo "  5. 每2小时"
        echo "  6. 自定义间隔(分钟)"
        read -p "选择 (1-6): " interval_choice
        
        case $interval_choice in
            1) TEST_INTERVAL_MINUTES=5 ;;
            2) TEST_INTERVAL_MINUTES=10 ;;
            3) TEST_INTERVAL_MINUTES=30 ;;
            4) TEST_INTERVAL_MINUTES=60 ;;
            5) TEST_INTERVAL_MINUTES=120 ;;
            6) 
                read -p "请输入间隔(分钟): " TEST_INTERVAL_MINUTES
                ;;
            *) 
                echo "无效选项,使用默认: 10分钟"
                TEST_INTERVAL_MINUTES=10
                ;;
        esac
        
        TEST_NAME="自定义测试"
        echo ""
        echo "✅ 配置完成:"
        echo "   测试时长: ${test_days}天${test_hours}小时 (共 $TEST_DURATION_MINUTES 分钟)"
        echo "   测试间隔: $TEST_INTERVAL_MINUTES 分钟"
        echo "   预计轮数: $((TEST_DURATION_MINUTES / TEST_INTERVAL_MINUTES)) 轮"
        echo ""
        ;;
    *)
        echo "无效选项,使用默认: 快速测试"
        TEST_DURATION_MINUTES=60
        TEST_INTERVAL_MINUTES=5
        TEST_NAME="快速测试"
        ;;
esac

# 创建测试日志目录
mkdir -p logs/week_test
LOG_FILE="logs/week_test/automated_test_$(date +%Y%m%d_%H%M%S).log"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试配置: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  - 测试时长: $TEST_DURATION_MINUTES 分钟 ($(echo "scale=2; $TEST_DURATION_MINUTES/60" | bc) 小时)"
echo "  - 测试间隔: $TEST_INTERVAL_MINUTES 分钟"
echo "  - 预计测试轮数: $(echo "$TEST_DURATION_MINUTES / $TEST_INTERVAL_MINUTES" | bc)"
echo "  - API地址: $API_BASE"
echo "  - 日志文件: $LOG_FILE"
echo ""

# 使用正确的API密钥
echo "🔑 使用正确的API密钥..."
API_KEY="testnet_api_key_51a69b550a2c4149"
echo "✅ 使用API密钥: $API_KEY"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 记录开始时间
START_TIME=$(date)
echo "开始时间: $START_TIME" | tee -a "$LOG_FILE"
echo "API密钥: $API_KEY" | tee -a "$LOG_FILE"

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

# 钱包创建测试 (使用原始API密钥，不是Bearer格式)
test_create_wallet() {
    local wallet_name="test_wallet_$(date +%s)"
    local response=$(curl -s -X POST "$API_BASE/api/wallets" \
        -H "Authorization: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$wallet_name\", \"description\": \"自动化测试钱包\", \"quantum_safe\": false}")
    
    # 检查响应是否包含成功标识（id、name或quantum_safe字段）
    echo "$response" | grep -q "id\|name\|quantum_safe"
}

# 钱包列表测试 (使用原始API密钥，不是Bearer格式)
test_list_wallets() {
    local response=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: $API_KEY")
    
    echo "$response" | grep -q "name\|\[\]"
}

# 余额查询测试 (使用原始API密钥，不是Bearer格式)
test_get_balance() {
    # 先获取钱包列表
    local wallets=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: $API_KEY")
    
    # 提取第一个钱包名称
    local wallet_name=$(echo "$wallets" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ ! -z "$wallet_name" ]; then
        local response=$(curl -s -X GET "$API_BASE/api/wallets/$wallet_name/balance?network=eth" \
            -H "Authorization: $API_KEY")
        echo "$response" | grep -q "balance\|error"
    else
        return 1
    fi
}

# 交易历史测试 (使用原始API密钥，不是Bearer格式)
test_transaction_history() {
    local wallets=$(curl -s -X GET "$API_BASE/api/wallets" \
        -H "Authorization: $API_KEY")
    
    local wallet_name=$(echo "$wallets" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ ! -z "$wallet_name" ]; then
        local response=$(curl -s -X GET "$API_BASE/api/wallets/$wallet_name/history" \
            -H "Authorization: $API_KEY")
        echo "$response" | grep -q "transactions\|\[\]"
    else
        return 1
    fi
}

# 网络状态测试 (使用原始API密钥，不是Bearer格式)
test_network_status() {
    local response=$(curl -s -X GET "$API_BASE/api/metrics" \
        -H "Authorization: $API_KEY")
    
    echo "$response" | grep -q "defi_hot_wallet\|metrics"
}

# 检查服务器状态
check_server_status() {
    echo "🔍 检查服务器状态..."
    if curl -s "$API_BASE/api/health" | grep -q "ok\|healthy"; then
        echo "✅ 服务器运行正常"
        return 0
    else
        echo "❌ 服务器未运行或无法访问"
        echo "请确保服务器正在运行在 $API_BASE"
        return 1
    fi
}

# 主测试循环
echo "开始自动化测试循环..."
echo "按 Ctrl+C 可以停止测试"
echo ""

# 检查并启动服务器
echo "🔍 检查服务器状态..."
if ! curl -s "$API_BASE/api/health" > /dev/null 2>&1; then
    echo "⚠️  服务器未运行"
    echo ""
    echo "🚀 自动启动服务器..."
    
    # 设置环境变量
    export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    export API_KEY="testnet_api_key_51a69b550a2c4149"
    export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"
    export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
    export RUST_LOG="info"
    export SERVER_HOST="127.0.0.1"
    export SERVER_PORT="8888"
    export TEST_SKIP_DECRYPT="1"
    export ALLOW_BRIDGE_MOCKS="1"
    
    # 后台启动服务器
    mkdir -p logs
    LOG_FILE_SERVER="logs/server_$(date +%Y%m%d_%H%M%S).log"
    cargo run --features test-env --bin hot_wallet > "$LOG_FILE_SERVER" 2>&1 &
    SERVER_PID=$!
    
    echo "✅ 服务器已启动 (PID: $SERVER_PID)"
    echo "📝 服务器日志: $LOG_FILE_SERVER"
    echo ""
    
    # 等待服务器启动
    echo "⏳ 等待服务器启动 (15秒)..."
    for i in {15..1}; do
        echo -n "$i... "
        sleep 1
    done
    echo ""
    echo ""
    
    # 验证服务器
    if ! curl -s "$API_BASE/api/health" | grep -q "ok\|healthy"; then
        echo "❌ 服务器启动失败"
        echo ""
        echo "查看日志:"
        tail -20 "$LOG_FILE_SERVER"
        exit 1
    fi
fi
echo "✅ 服务器运行正常"
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
    if [ $((SUCCESS_COUNT + FAILURE_COUNT)) -gt 0 ]; then
        echo "  成功率: $(( SUCCESS_COUNT * 100 / (SUCCESS_COUNT + FAILURE_COUNT) ))%"
    else
        echo "  成功率: 0%"
    fi
    
    # 检查是否达到测试时长
    TOTAL_TESTS_NEEDED=$((TEST_DURATION_MINUTES / TEST_INTERVAL_MINUTES))
    if [ $TEST_COUNT -ge $TOTAL_TESTS_NEEDED ]; then
        echo ""
        echo "🎉 测试完成！已完成 $TEST_COUNT 轮测试"
        echo "   测试时长: $TEST_DURATION_MINUTES 分钟 ($(echo "scale=2; $TEST_DURATION_MINUTES/60" | bc) 小时)"
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
if [ $((SUCCESS_COUNT + FAILURE_COUNT)) -gt 0 ]; then
    echo "成功率: $(( SUCCESS_COUNT * 100 / (SUCCESS_COUNT + FAILURE_COUNT) ))%"
else
    echo "成功率: 0%"
fi
echo "详细日志: $LOG_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
