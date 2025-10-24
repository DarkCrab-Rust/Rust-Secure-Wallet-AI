#!/bin/bash

echo "🚀 测试网快速启动 - 1周自动化测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 检查环境..."
if [ ! -f "start_testnet.sh" ]; then
    echo "❌ 找不到 start_testnet.sh 文件"
    exit 1
fi

if [ ! -f "restart_testnet.sh" ]; then
    echo "❌ 找不到 restart_testnet.sh 文件"
    exit 1
fi

if [ ! -f "week_automated_test.sh" ]; then
    echo "❌ 找不到 week_automated_test.sh 文件"
    exit 1
fi

echo "✅ 环境检查完成"

echo ""
echo "Step 2: 重新启动测试网..."
chmod +x restart_testnet.sh
./restart_testnet.sh

if [ $? -ne 0 ]; then
    echo "❌ 测试网启动失败"
    exit 1
fi

echo ""
echo "Step 3: 等待服务器完全启动..."
sleep 15

echo ""
echo "Step 4: 验证服务器状态..."
HEALTH_CHECK=$(curl -s http://localhost:8080/health)
if echo "$HEALTH_CHECK" | grep -q "ok\|healthy"; then
    echo "✅ 服务器健康检查通过"
else
    echo "❌ 服务器健康检查失败: $HEALTH_CHECK"
    echo "请检查服务器日志"
    exit 1
fi

echo ""
echo "Step 5: 启动1周自动化测试..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "自动化测试将在后台运行，包含以下功能："
echo "  - 健康检查"
echo "  - 钱包创建和管理"
echo "  - 余额查询"
echo "  - 交易历史查询"
echo "  - 网络状态检查"
echo ""
echo "测试间隔: 30分钟"
echo "测试时长: 7天"
echo "日志文件: logs/week_test/"
echo ""
echo "按 Ctrl+C 可以停止自动化测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

chmod +x week_automated_test.sh
./week_automated_test.sh

echo ""
echo "🎉 测试网1周自动化测试完成！"
