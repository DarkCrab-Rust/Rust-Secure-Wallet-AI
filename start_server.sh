#!/bin/bash

# 🚀 一键启动服务器

echo "=========================================="
echo "🚀 DeFi热钱包 - 启动服务器"
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
        echo "❌ 取消启动"
        exit 1
    fi
fi

echo "✅ 端口8888可用"
echo ""

# 设置环境变量
echo "🔧 设置环境变量..."
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
export API_KEY="testnet_api_key_51a69b550a2c4149"
# Respect external CORS_ALLOW_ORIGIN if provided
export CORS_ALLOW_ORIGIN="${CORS_ALLOW_ORIGIN:-http://localhost:3000,http://localhost:3010}"
export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
export RUST_LOG="info"
export SERVER_HOST="127.0.0.1"
export SERVER_PORT="8888"
export TEST_SKIP_DECRYPT="1"
export ALLOW_BRIDGE_MOCKS="1"

echo "✅ 环境变量已设置"
echo ""

# 显示配置信息
echo "📋 服务器配置:"
echo "  - API密钥: $API_KEY"
echo "  - 服务器地址: $SERVER_HOST:$SERVER_PORT"
echo "  - 数据库: $DATABASE_URL"
echo "  - CORS: $CORS_ALLOW_ORIGIN"
echo ""

echo "=========================================="
echo "🚀 正在启动服务器..."
echo "=========================================="
echo ""
echo "⚠️  提示:"
echo "  - 服务器将在前台运行"
echo "  - 按 Ctrl+C 可以停止服务器"
echo "  - 请在新终端窗口运行测试"
echo ""
echo "=========================================="
echo ""

# 启动服务器
cargo run --features test-env --bin hot_wallet

