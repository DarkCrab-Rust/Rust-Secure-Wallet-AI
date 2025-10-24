#!/bin/bash

echo "🎯 Day 5: 运行所有 Week 1 测试（正确版本）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

echo "📝 运行 Day 1 测试 (19个)..."
cargo test --test week1_day1_wallet_core_tests -- --test-threads=20
DAY1_EXIT=$?
echo ""

echo "📝 运行 Day 2 测试 (19个)..."
cargo test --test week1_day2_wallet_backup_restore_tests -- --test-threads=20
DAY2_EXIT=$?
echo ""

echo "📝 运行 Day 3 测试 (24个)..."
cargo test --test week1_day3_crypto_signing_tests -- --test-threads=20
DAY3_EXIT=$?
echo ""

echo "📝 运行 Day 4 测试 (34个)..."
cargo test --test week1_day4_api_auth_endpoints_tests -- --test-threads=20
DAY4_EXIT=$?
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Week 1 测试总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL_FAILED=0

if [ $DAY1_EXIT -eq 0 ]; then
    echo "✅ Day 1: 19个测试通过"
else
    echo "❌ Day 1: 失败"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

if [ $DAY2_EXIT -eq 0 ]; then
    echo "✅ Day 2: 19个测试通过"
else
    echo "❌ Day 2: 失败"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

if [ $DAY3_EXIT -eq 0 ]; then
    echo "✅ Day 3: 24个测试通过"
else
    echo "❌ Day 3: 失败"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

if [ $DAY4_EXIT -eq 0 ]; then
    echo "✅ Day 4: 34个测试通过"
else
    echo "❌ Day 4: 失败"
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "🎉 所有 96 个测试全部通过！"
    echo ""
    echo "预期覆盖率: ~87%"
    echo ""
    echo "下一步: 生成覆盖率报告"
    echo "  chmod +x generate_week1_coverage_report.sh"
    echo "  ./generate_week1_coverage_report.sh"
    exit 0
else
    echo "⚠️  有 $TOTAL_FAILED 天的测试失败"
    exit 1
fi

