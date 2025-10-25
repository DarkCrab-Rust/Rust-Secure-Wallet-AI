#!/bin/bash

# 🚀 一键启动服务器并测试

echo "=========================================="
echo "🚀 DeFi热钱包 - 一键启动并测试"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 检查端口是否被占用
echo "🔍 检查端口8888..."
if netstat -ano | grep :8888 | grep LISTENING > /dev/null; then
    echo "⚠️  端口8888已被占用"
    echo ""
    read -p "是否停止现有服务器并重启? (y/n): " choice
    if [ "$choice" = "y" ]; then
        echo "正在停止现有服务器..."
        PID=$(netstat -ano | grep :8888 | grep LISTENING | awk '{print $5}' | head -1)
        if [ ! -z "$PID" ]; then
            taskkill //F //PID $PID
            echo "✅ 已停止旧服务器"
            sleep 2
        fi
    else
        echo "⚠️  使用现有服务器进行测试"
        echo ""
        bash quick_test.sh
        exit 0
    fi
fi

echo "✅ 端口8888可用"
echo ""

# 设置环境变量
echo "🔧 设置环境变量..."
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
export API_KEY="testnet_api_key_51a69b550a2c4149"
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"
export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
export RUST_LOG="info"
export SERVER_HOST="127.0.0.1"
export SERVER_PORT="8888"
export TEST_SKIP_DECRYPT="1"
export ALLOW_BRIDGE_MOCKS="1"

echo "✅ 环境变量已设置"
echo ""

# 后台启动服务器
echo "=========================================="
echo "🚀 启动服务器..."
echo "=========================================="
echo ""

# 启动服务器并重定向输出到日志
mkdir -p logs
LOG_FILE="logs/server_$(date +%Y%m%d_%H%M%S).log"
cargo run --features test-env --bin hot_wallet > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

echo "✅ 服务器已在后台启动 (PID: $SERVER_PID)"
echo "📝 日志文件: $LOG_FILE"
echo ""

# 等待服务器启动
echo "⏳ 等待服务器启动 (15秒)..."
for i in {15..1}; do
    echo -n "$i... "
    sleep 1
done
echo ""
echo ""

# 验证服务器是否启动成功
echo "🔍 验证服务器状态..."
if curl -s http://localhost:8888/api/health | grep -q "ok\|healthy"; then
    echo "✅ 服务器启动成功!"
    echo ""
else
    echo "❌ 服务器启动失败"
    echo ""
    echo "查看日志:"
    tail -20 "$LOG_FILE"
    exit 1
fi

# 运行快速测试
echo "=========================================="
echo "🧪 开始运行测试..."
echo "=========================================="
echo ""

bash quick_test.sh

echo ""
echo "=========================================="
echo "✅ 完成!"
echo "=========================================="
echo ""
echo "📝 服务器信息:"
echo "  - PID: $SERVER_PID"
echo "  - 地址: http://localhost:8888"
echo "  - 日志: $LOG_FILE"
echo ""
echo "🛑 停止服务器:"
echo "  bash manage_server.sh"
echo ""

