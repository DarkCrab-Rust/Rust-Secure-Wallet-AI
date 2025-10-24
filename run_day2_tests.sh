#!/bin/bash

echo "🚀 运行 Day 2 钱包备份和恢复测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

# 运行Day 2测试
cargo test week1_day2_wallet_backup_restore_tests -- --test-threads=20 --nocapture

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Day 2 所有测试通过！"
    echo ""
    echo "📊 Day 1 + Day 2 完成，现在运行所有测试..."
    cargo test week1_day1_wallet_core_tests week1_day2_wallet_backup_restore_tests -- --test-threads=20
    echo ""
    echo "✅ Day 1-2 累计测试完成！"
else
    echo "❌ 测试失败，退出码: $TEST_EXIT_CODE"
fi

exit $TEST_EXIT_CODE

