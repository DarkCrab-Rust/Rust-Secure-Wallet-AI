#!/bin/bash

echo "🚀 启动测试网并验证Day 2修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 检查端口状态..."
if netstat -ano | grep -q ":8888"; then
    echo "⚠️ 端口8888被占用，正在清理..."
    # 查找并停止占用端口的进程
    for pid in $(netstat -ano | grep ":8888" | awk '{print $5}' | sort -u); do
        if [ "$pid" != "0" ]; then
            echo "停止进程 $pid"
            taskkill //F //PID $pid 2>/dev/null || true
        fi
    done
    sleep 2
else
    echo "✅ 端口8888可用"
fi

echo ""
echo "Step 2: 启动测试网服务器..."
echo "服务器将在后台启动，请稍等..."

# 启动服务器
nohup ./start_testnet.sh > server.log 2>&1 &
SERVER_PID=$!

echo "服务器进程ID: $SERVER_PID"
echo "等待服务器启动..."
sleep 15

echo ""
echo "Step 3: 检查服务器状态..."
if curl -s http://localhost:8888/health >/dev/null 2>&1; then
    echo "✅ 服务器启动成功！"
else
    echo "❌ 服务器启动失败，检查日志..."
    tail -20 server.log
    exit 1
fi

echo ""
echo "Step 4: 运行API测试..."
chmod +x 快速测试API.sh
./快速测试API.sh

echo ""
echo "Step 5: 启动1周自动化测试..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "自动化测试将在后台运行..."
echo "测试间隔: 30分钟"
echo "测试时长: 7天"
echo "日志目录: logs/week_test/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 启动自动化测试
nohup ./week_automated_test.sh > automated_test.log 2>&1 &
TEST_PID=$!

echo "自动化测试进程ID: $TEST_PID"
echo ""
echo "🎉 测试网和自动化测试已启动！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "服务器地址: http://localhost:8888"
echo "服务器日志: server.log"
echo "测试日志: automated_test.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
