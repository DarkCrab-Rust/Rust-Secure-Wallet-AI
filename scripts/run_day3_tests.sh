#!/bin/bash

echo "🚀 运行 Day 3 加密签名和验证测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

# 运行Day 3测试
cargo test --test week1_day3_crypto_signing_tests -- --test-threads=20

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Day 3 所有测试通过！"
    echo ""
    echo "📊 Week 1 累计进度："
    echo "  Day 1: 19个测试 ✅"
    echo "  Day 2: 19个测试 ✅"
    echo "  Day 3: 18个测试 ✅"
    echo "  ━━━━━━━━━━━━━━━━━━━"
    echo "  总计:  56个测试 ✅"
else
    echo "❌ 测试失败，退出码: $TEST_EXIT_CODE"
fi

exit $TEST_EXIT_CODE

