#!/bin/bash

echo "🚀 运行 Day 1 核心钱包管理测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

# 运行Day 1测试
cargo test week1_day1_wallet_core_tests -- --test-threads=20 --nocapture

echo ""
echo "✅ Day 1 测试完成！"

