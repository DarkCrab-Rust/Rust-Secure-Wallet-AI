#!/bin/bash

echo "🚀 简单启动测试网"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 清理端口..."
# 停止可能占用端口的进程
pkill -f hot_wallet 2>/dev/null || true
sleep 2

echo "Step 2: 直接启动服务器..."
echo "服务器将在前台运行，按 Ctrl+C 停止"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 直接运行cargo，不使用脚本
cargo run --bin hot_wallet
