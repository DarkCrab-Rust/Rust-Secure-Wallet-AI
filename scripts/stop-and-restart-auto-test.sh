#!/bin/bash

echo "🔄 停止并重启自动化测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 停止当前的自动化测试..."
# 停止week_automated_test.sh进程
pkill -f week_automated_test.sh 2>/dev/null || echo "没有找到运行中的自动化测试进程"

echo "Step 2: 等待进程完全停止..."
sleep 3

echo "Step 3: 验证服务器状态..."
chmod +x 验证服务器运行状态.sh
./验证服务器运行状态.sh

echo ""
echo "Step 4: 如果服务器正常，重启自动化测试..."
if curl -s http://localhost:8888/health | grep -q "ok\|healthy"; then
    echo "✅ 服务器运行正常，重启自动化测试..."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 启动修复后的1周自动化测试"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "测试配置:"
    echo "  - API地址: http://localhost:8888 (已修复)"
    echo "  - API密钥: testnet_api_key_117ca14556c34271 (已修复)"
    echo "  - 测试间隔: 30分钟"
    echo "  - 测试时长: 7天"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 启动修复后的自动化测试
    chmod +x week_automated_test.sh
    ./week_automated_test.sh
else
    echo "❌ 服务器未运行，请先启动服务器："
    echo "cargo run --bin hot_wallet"
fi
