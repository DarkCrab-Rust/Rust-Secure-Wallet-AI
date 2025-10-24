#!/bin/bash

echo "🔧 测试修复后的存储层测试..."
echo ""

cargo test --test sprint_storage_tests -- --test-threads=20

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 存储层测试全部通过！"
else
    echo ""
    echo "❌ 存储层测试仍有问题"
fi
