#!/bin/bash

echo "🔧 Day 2: 测试余额查询修复"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Step 1: 编译修复后的代码..."
cargo build --bin hot_wallet

if [ $? -ne 0 ]; then
    echo "❌ 编译失败！请检查错误信息"
    exit 1
fi

echo "✅ 编译成功！"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: 重新启动服务器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "请执行以下操作:"
echo ""
echo "1. 在终端1（服务器终端）按 Ctrl+C 停止旧服务器"
echo ""
echo "2. 重新启动服务器:"
echo "   cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet"
echo "   ./start_testnet.sh"
echo ""
echo "3. 看到 'Server listening on 127.0.0.1:8888' 后"
echo "   在终端2运行:"
echo "   ./day2_verify_balance.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

