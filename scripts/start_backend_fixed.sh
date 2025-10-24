#!/bin/bash

echo "🔧 修复并启动后端服务器..."

# 进入后端目录
cd "$(dirname "$0")"

# 创建数据库文件（如果不存在）
if [ ! -f wallets.db ]; then
    echo "📁 创建数据库文件..."
    touch wallets.db
    echo "✅ 数据库文件创建成功"
fi

# 设置环境变量
export DATABASE_URL="sqlite://wallets.db?mode=rwc"
export API_KEY=test_api_key
export RUST_LOG=info

echo ""
echo "🚀 启动Rust区块链钱包后端服务器..."
echo "📍 服务器地址: http://localhost:8888"
echo "🔑 API密钥: test_api_key"
echo "💾 数据库: wallets.db"
echo ""

# 启动服务器
cargo run --bin hot_wallet

