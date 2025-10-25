#!/bin/bash

# 🧪 快速测试所有API

echo "=========================================="
echo "🧪 DeFi热钱包 - 快速API测试"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 配置
API_BASE="http://localhost:8888"
API_KEY="testnet_api_key_51a69b550a2c4149"

# 测试计数
TOTAL=0
SUCCESS=0
FAILED=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL++))
    echo "[$TOTAL] 测试: $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo "    ✅ 成功"
        ((SUCCESS++))
    else
        echo "    ❌ 失败"
        ((FAILED++))
    fi
    echo ""
}

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
    LOG_FILE="logs/server_$(date +%Y%m%d_%H%M%S).log"
    cargo run --features test-env --bin hot_wallet > "$LOG_FILE" 2>&1 &
    SERVER_PID=$!
    
    echo "✅ 服务器已启动 (PID: $SERVER_PID)"
    echo "📝 日志: $LOG_FILE"
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
        tail -20 "$LOG_FILE"
        exit 1
    fi
fi
echo "✅ 服务器运行正常"
echo ""

echo "=========================================="
echo "开始测试..."
echo "=========================================="
echo ""

# 1. 健康检查
run_test "健康检查" "curl -s '$API_BASE/api/health' | grep -q 'ok\|healthy'"

# 2. 钱包列表
run_test "钱包列表" "curl -s -X GET '$API_BASE/api/wallets' -H 'Authorization: $API_KEY' | grep -q 'name\|\[\]'"

# 3. 创建钱包
WALLET_NAME="test_wallet_$(date +%s)"
run_test "创建钱包" "curl -s -X POST '$API_BASE/api/wallets' \
    -H 'Authorization: $API_KEY' \
    -H 'Content-Type: application/json' \
    -d '{\"name\": \"$WALLET_NAME\", \"description\": \"快速测试钱包\", \"quantum_safe\": false}' \
    | grep -q 'id\|name\|quantum_safe'"

# 4. 余额查询
run_test "余额查询" "curl -s -X GET '$API_BASE/api/wallets/$WALLET_NAME/balance?network=eth' \
    -H 'Authorization: $API_KEY' | grep -q 'balance\|error'"

# 5. 交易历史
run_test "交易历史" "curl -s -X GET '$API_BASE/api/wallets/$WALLET_NAME/history' \
    -H 'Authorization: $API_KEY' | grep -q 'transactions\|\[\]'"

# 6. 网络状态
run_test "网络状态" "curl -s -X GET '$API_BASE/api/metrics' \
    -H 'Authorization: $API_KEY' | grep -q 'defi_hot_wallet\|metrics'"

# 显示结果
echo "=========================================="
echo "📊 测试结果"
echo "=========================================="
echo ""
echo "总测试数: $TOTAL"
echo "成功: $SUCCESS ✅"
echo "失败: $FAILED ❌"
if [ $TOTAL -gt 0 ]; then
    echo "成功率: $(( SUCCESS * 100 / TOTAL ))%"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 所有测试通过!"
else
    echo "⚠️  部分测试失败，请检查日志"
fi

echo "=========================================="

