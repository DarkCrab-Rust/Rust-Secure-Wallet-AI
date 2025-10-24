#!/bin/bash

echo "🔧 修复端口冲突并启动测试网"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 停止占用8888端口的进程..."
# 停止进程ID 25192
taskkill //F //PID 25192 2>/dev/null || echo "进程已停止"

echo "Step 2: 等待端口释放..."
sleep 3

echo "Step 3: 验证端口已释放..."
if netstat -ano | grep -q ":8888"; then
    echo "⚠️ 端口仍被占用，强制清理..."
    # 强制停止所有占用8888端口的进程
    for pid in $(netstat -ano | grep ":8888" | awk '{print $5}' | sort -u); do
        if [ "$pid" != "0" ]; then
            echo "停止进程 $pid"
            taskkill //F //PID $pid 2>/dev/null || true
        fi
    done
    sleep 2
else
    echo "✅ 端口已释放"
fi

echo ""
echo "Step 4: 启动测试网服务器..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "服务器将在前台运行，按 Ctrl+C 停止"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 启动服务器
cargo run --bin hot_wallet
