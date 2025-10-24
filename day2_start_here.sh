#!/bin/bash

echo "🌅 Day 2: 诊断和修复余额查询"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查服务器是否运行
if ! curl -s http://localhost:8888/api/health > /dev/null 2>&1; then
    echo "❌ 服务器未运行！"
    echo ""
    echo "请先启动服务器:"
    echo "  cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet"
    echo "  ./start_testnet.sh"
    exit 1
fi

echo "✅ 服务器正在运行"
echo ""

# 运行诊断
echo "🔍 开始诊断余额查询问题..."
echo ""

chmod +x diagnose_balance.sh
./diagnose_balance.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 诊断完成！请查看上面的输出"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

