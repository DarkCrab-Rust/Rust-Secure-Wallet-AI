#!/bin/bash
# 删除GitHub上所有无用分支，只保留main

cd "$(dirname "$0")"

echo "=========================================="
echo "删除GitHub上的无用分支"
echo "=========================================="
echo ""
echo "此操作将删除以下分支:"
echo "- archive-bridge-stub"
echo "- 功能/API改进"
echo "- 功能/api改进-修复"
echo "- 功能/ci-tests-secretvec"
echo "- 功能/cli-secretvec"
echo "- 功能/加密-secretvec"
echo "- 特性/新功能"
echo "- 功能/secretvec-foundation"
echo "- 安全/secretvec-ci"
echo ""
echo "只保留: main 分支"
echo ""

read -p "确定要删除这些分支吗？(输入 YES 继续): " confirm

if [ "$confirm" != "YES" ]; then
    echo "❌ 操作已取消"
    exit 1
fi

echo ""
echo "开始删除分支..."
echo ""

# 要删除的分支列表
branches=(
    "archive-bridge-stub"
    "功能/API改进"
    "功能/api改进-修复"
    "功能/ci-tests-secretvec"
    "功能/cli-secretvec"
    "功能/加密-secretvec"
    "特性/新功能"
    "功能/secretvec-foundation"
    "安全/secretvec-ci"
)

success_count=0
fail_count=0

for branch in "${branches[@]}"; do
    echo "删除分支: $branch"
    git push origin --delete "$branch" 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ 删除成功: $branch"
        ((success_count++))
    else
        echo "⚠️  删除失败或分支不存在: $branch"
        ((fail_count++))
    fi
    echo ""
done

echo "=========================================="
echo "删除完成"
echo "=========================================="
echo ""
echo "成功删除: $success_count 个分支"
echo "失败或不存在: $fail_count 个分支"
echo ""
echo "现在只保留 main 分支"
echo ""
echo "验证:"
echo "访问: https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/branches"
echo ""

