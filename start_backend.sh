#!/bin/bash

# 启动后端钱包服务器
# 设置环境变量
export RUST_LOG=info
export API_KEY=test_api_key

echo "🚀 启动Rust区块链钱包后端服务器..."
echo "📍 服务器地址: http://localhost:8888"
echo "🔑 API密钥: test_api_key"
echo ""

# 启动服务器
cargo run --bin hot_wallet
