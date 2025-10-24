#!/bin/bash

echo "🔧 编译并运行 Day 1 核心钱包管理测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

# 清理之前的编译
echo "清理编译缓存..."
cargo clean -p defi-hot-wallet

echo ""
echo "重新编译并运行测试..."
cargo test week1_day1_wallet_core_tests -- --test-threads=20 --nocapture

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Day 1 所有测试通过！"
    echo ""
    echo "📊 生成覆盖率报告..."
    cargo tarpaulin --out Html --output-dir coverage --test week1_day1_wallet_core_tests
    echo ""
    echo "✅ 覆盖率报告已生成: coverage/index.html"
else
    echo "❌ 测试失败，退出码: $TEST_EXIT_CODE"
fi

exit $TEST_EXIT_CODE

