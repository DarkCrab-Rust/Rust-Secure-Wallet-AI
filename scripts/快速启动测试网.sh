#!/bin/bash

echo "🚀 快速启动测试网"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 确保在正确的目录
cd "$(dirname "$0")"

echo "当前目录: $(pwd)"
echo "检查 start_testnet.sh 文件..."

if [ -f "start_testnet.sh" ]; then
    echo "✅ 找到 start_testnet.sh 文件"
    echo "正在启动测试网..."
    echo ""
    
    # 给脚本执行权限
    chmod +x start_testnet.sh
    
    # 启动测试网
    ./start_testnet.sh
else
    echo "❌ 找不到 start_testnet.sh 文件"
    echo "请确保在正确的项目目录中运行此脚本"
    echo "当前目录内容:"
    ls -la
    exit 1
fi
