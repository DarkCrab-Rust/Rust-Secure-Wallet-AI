#!/bin/bash

echo "🚀 运行存储层冲刺测试..."
echo ""

cd "$(dirname "$0")"

cargo test --test sprint_storage_tests -- --test-threads=20

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 存储层测试全部通过！"
else
    echo ""
    echo "❌ 存储层测试失败"
    exit 1
fi

