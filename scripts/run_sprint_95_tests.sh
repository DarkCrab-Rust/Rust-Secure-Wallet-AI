#!/bin/bash

echo "🚀 冲刺95%: 运行新增测试..."
echo ""

cd "$(dirname "$0")"

echo "📝 运行区块链交互测试..."
cargo test --test sprint_95_blockchain_tests -- --test-threads=20
BLOCKCHAIN_EXIT=$?
echo ""

echo "📝 运行配置和错误处理测试..."
cargo test --test sprint_95_config_error_tests -- --test-threads=20
CONFIG_EXIT=$?
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 新增测试总结"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $BLOCKCHAIN_EXIT -eq 0 ]; then
    echo "✅ 区块链交互测试通过"
else
    echo "❌ 区块链交互测试失败"
fi

if [ $CONFIG_EXIT -eq 0 ]; then
    echo "✅ 配置和错误处理测试通过"
else
    echo "❌ 配置和错误处理测试失败"
fi

echo ""

if [ $BLOCKCHAIN_EXIT -eq 0 ] && [ $CONFIG_EXIT -eq 0 ]; then
    echo "🎉 所有新增测试通过！"
    echo ""
    echo "下一步: 运行所有测试验证95%覆盖率"
    echo "  ./run_all_tests_95.sh"
    exit 0
else
    echo "❌ 部分测试失败"
    exit 1
fi

