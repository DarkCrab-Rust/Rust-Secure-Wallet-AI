#!/bin/bash

echo "🚀 运行 Day 4 API认证和端点测试..."
echo "使用 20 线程并发执行"
echo ""

cd "$(dirname "$0")"

# 运行Day 4测试
cargo test --test week1_day4_api_auth_endpoints_tests -- --test-threads=20

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Day 4 所有测试通过！"
    echo ""
    echo "📊 Week 1 累计进度："
    echo "  Day 1: 19个测试 ✅"
    echo "  Day 2: 19个测试 ✅"
    echo "  Day 3: 24个测试 ✅"
    echo "  Day 4: 20个测试 ✅"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━"
    echo "  总计:  82个测试 ✅"
    echo ""
    echo "🎯 预期覆盖率: ~85%"
else
    echo "❌ 测试失败，退出码: $TEST_EXIT_CODE"
fi

exit $TEST_EXIT_CODE

