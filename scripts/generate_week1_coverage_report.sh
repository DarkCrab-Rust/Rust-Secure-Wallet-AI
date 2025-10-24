#!/bin/bash

echo "📊 Day 5: 生成 Week 1 覆盖率报告"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$(dirname "$0")"

echo "🔍 运行覆盖率分析..."
echo "这可能需要几分钟，请耐心等待..."
echo ""

# 生成覆盖率报告（只包含Week 1的测试）
cargo tarpaulin \
  --out Html \
  --output-dir coverage \
  --test-threads 20 \
  --timeout 300 \
  --exclude-files 'tests/*' 'target/*' 'defi-target/*' \
  -- week1_

COVERAGE_EXIT=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $COVERAGE_EXIT -eq 0 ]; then
    echo "✅ 覆盖率报告生成成功！"
    echo ""
    echo "📁 报告位置: coverage/index.html"
    echo "📁 报告位置: $(pwd)/coverage/index.html"
    echo ""
    echo "🌐 在浏览器中打开查看详细覆盖率数据"
    echo ""
    echo "下一步: 分析报告，查看覆盖率百分比"
else
    echo "❌ 覆盖率报告生成失败，退出码: $COVERAGE_EXIT"
    echo ""
    echo "可能的问题:"
    echo "1. tarpaulin 未安装 - 运行: cargo install cargo-tarpaulin"
    echo "2. 测试失败 - 先运行测试确保全部通过"
    echo "3. 超时 - 增加 --timeout 参数"
fi

exit $COVERAGE_EXIT

