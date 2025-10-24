#!/bin/bash

echo "🚀 重新启动测试网 - Day 2"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 切换到项目目录
cd "$(dirname "$0")"

echo "Step 1: 停止可能运行的服务器进程..."
# 查找并停止占用8080端口的进程
if command -v netstat >/dev/null 2>&1; then
    PID=$(netstat -ano | grep :8080 | awk '{print $5}' | head -1)
    if [ ! -z "$PID" ]; then
        echo "发现进程 $PID 占用8080端口，正在停止..."
        taskkill //F //PID $PID 2>/dev/null || echo "进程已停止"
    fi
fi

echo "Step 2: 清理编译缓存..."
# 删除可能锁定的文件
rm -f defi-target/debug/hot_wallet.exe 2>/dev/null || true
rm -f target/debug/hot_wallet.exe 2>/dev/null || true

echo "Step 3: 重新编译项目..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✅ 编译成功！"
    echo ""
    echo "Step 4: 启动测试网服务器..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "服务器将在后台启动，请稍等..."
    
    # 启动服务器
    ./start_testnet.sh &
    SERVER_PID=$!
    
    echo "服务器进程ID: $SERVER_PID"
    echo "等待服务器启动..."
    sleep 10
    
    echo ""
    echo "Step 5: 验证服务器状态..."
    curl -s http://localhost:8080/health || echo "服务器可能还在启动中..."
    
    echo ""
    echo "🎉 测试网重新启动完成！"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "服务器地址: http://localhost:8080"
    echo "API文档: http://localhost:8080/docs"
    echo "健康检查: http://localhost:8080/health"
    echo ""
    echo "现在可以运行自动化测试脚本了！"
    
else
    echo "❌ 编译失败！请检查错误信息"
    exit 1
fi
