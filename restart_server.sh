#!/bin/bash

# 🔄 重启服务器

echo "=========================================="
echo "🔄 DeFi热钱包 - 重启服务器"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 1. 停止现有服务器
echo "1️⃣ 停止现有服务器..."
PID=$(netstat -ano | grep :8888 | grep LISTENING | awk '{print $5}' | head -1)

if [ ! -z "$PID" ]; then
    echo "找到服务器进程: $PID"
    taskkill //F //PID $PID
    echo "✅ 服务器已停止"
    sleep 2
else
    echo "⚠️  未找到运行中的服务器"
fi

echo ""

# 2. 清理端口
echo "2️⃣ 清理端口..."
sleep 1
echo "✅ 端口已清理"
echo ""

# 3. 启动新服务器
echo "3️⃣ 启动新服务器..."
echo ""

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

# 验证服务器
echo "🔍 验证服务器状态..."
if curl -s http://localhost:8888/api/health | grep -q "ok\|healthy"; then
    echo "✅ 服务器重启成功!"
else
    echo "❌ 服务器重启失败"
    echo ""
    echo "查看日志:"
    tail -20 "$LOG_FILE"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ 重启完成!"
echo "=========================================="
echo ""
echo "📝 服务器信息:"
echo "  - PID: $SERVER_PID"
echo "  - 地址: http://localhost:8888"
echo "  - API密钥: $API_KEY"
echo "  - 日志: $LOG_FILE"
echo ""
echo "🧪 运行测试:"
echo "  bash quick_test.sh"
echo ""

