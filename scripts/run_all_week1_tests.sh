#!/bin/bash

echo "🚀 运行所有 Week 1 测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

echo "运行 Day 1 测试..."
cargo test --test week1_day1_wallet_core_tests -- --test-threads=20

DAY1_EXIT=$?

echo ""
echo "运行 Day 2 测试..."
cargo test --test week1_day2_wallet_backup_restore_tests -- --test-threads=20

DAY2_EXIT=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 测试总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $DAY1_EXIT -eq 0 ]; then
    echo "✅ Day 1: 通过"
else
    echo "❌ Day 1: 失败"
fi

if [ $DAY2_EXIT -eq 0 ]; then
    echo "✅ Day 2: 通过"
else
    echo "❌ Day 2: 失败"
fi

if [ $DAY1_EXIT -eq 0 ] && [ $DAY2_EXIT -eq 0 ]; then
    echo ""
    echo "🎉 Week 1 Day 1-2 所有测试通过！"
    exit 0
else
    echo ""
    echo "⚠️  部分测试失败"
    exit 1
fi

