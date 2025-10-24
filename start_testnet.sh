#!/bin/bash

echo "🚀 启动测试网钱包服务器..."
echo ""

# ============================================
# 生成安全的测试密钥
# ============================================

echo "🔑 生成安全的测试密钥..."

# 生成32字节随机密钥并base64编码
WALLET_ENC_KEY=$(openssl rand -base64 32)
echo "✅ WALLET_ENC_KEY已生成"

# ============================================
# 设置环境变量
# ============================================

export WALLET_ENC_KEY="$WALLET_ENC_KEY"
export API_KEY="testnet_api_key_$(openssl rand -hex 8)"
export CORS_ALLOW_ORIGIN="http://localhost:3000"
export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
export RUST_LOG=info
export SERVER_HOST=127.0.0.1
export SERVER_PORT=8888

# ============================================
# 创建数据目录
# ============================================

mkdir -p data

# ============================================
# 保存密钥到文件 (重要!)
# ============================================

cat > .env.testnet.local << EOF
# 测试网环境变量 (本次会话)
# 生成时间: $(date)

WALLET_ENC_KEY=$WALLET_ENC_KEY
API_KEY=$API_KEY
CORS_ALLOW_ORIGIN=$CORS_ALLOW_ORIGIN
DATABASE_URL=$DATABASE_URL
RUST_LOG=$RUST_LOG
SERVER_HOST=$SERVER_HOST
SERVER_PORT=$SERVER_PORT
EOF

echo ""
echo "✅ 环境变量已设置并保存到 .env.testnet.local"
echo ""
echo "⚠️  重要: 请保存好这个文件中的密钥！"
echo "   如果丢失，将无法解密钱包数据！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "环境配置:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "API密钥: $API_KEY"
echo "CORS源: $CORS_ALLOW_ORIGIN"
echo "数据库: $DATABASE_URL"
echo "日志级别: $RUST_LOG"
echo "服务器: $SERVER_HOST:$SERVER_PORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🚀 正在启动服务器..."
echo ""

# ============================================
# 启动服务
# ============================================

cargo run --bin hot_wallet

