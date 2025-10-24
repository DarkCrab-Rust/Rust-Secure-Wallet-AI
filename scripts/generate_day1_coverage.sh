#!/bin/bash

echo "📊 生成 Day 1 测试覆盖率报告..."
echo ""

cd "$(dirname "$0")"

# 生成覆盖率报告
cargo tarpaulin --out Html --output-dir coverage --test-threads=20

echo ""
echo "✅ 覆盖率报告已生成！"
echo "📁 报告位置: coverage/index.html"
echo ""
echo "请在浏览器中打开查看详细覆盖率数据"

