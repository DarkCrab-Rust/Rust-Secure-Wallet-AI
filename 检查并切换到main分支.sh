#!/bin/bash
# 检查当前分支并确保推送到main分支

cd "$(dirname "$0")"

echo "=========================================="
echo "检查分支状态"
echo "=========================================="
echo ""

echo "[1/7] 查看当前分支..."
CURRENT_BRANCH=$(git branch --show-current)
echo "当前本地分支: $CURRENT_BRANCH"
echo ""

echo "[2/7] 查看所有本地分支..."
git branch
echo ""

echo "[3/7] 查看所有远程分支..."
git branch -r
echo ""

echo "[4/7] 获取最新远程信息..."
git fetch origin
echo ""

echo "[5/7] 检查main分支状态..."
if git show-ref --verify --quiet refs/heads/main; then
    echo "✅ 本地有main分支"
    git log main --oneline -5
else
    echo "⚠️  本地没有main分支，从远程检出..."
    git checkout -b main origin/main
fi
echo ""

echo "[6/7] 切换到main分支..."
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "当前在 $CURRENT_BRANCH 分支，切换到main..."
    git checkout main
    if [ $? -eq 0 ]; then
        echo "✅ 成功切换到main分支"
    else
        echo "❌ 切换失败"
        exit 1
    fi
else
    echo "✅ 已经在main分支上"
fi
echo ""

echo "[7/7] 检查main分支的文件..."
echo "main分支的最近提交:"
git log main --oneline -10
echo ""
echo "main分支的文件数量:"
git ls-tree -r main --name-only | wc -l
echo ""

echo "=========================================="
echo "分支状态总结"
echo "=========================================="
echo ""
echo "当前本地分支: $(git branch --show-current)"
echo "本地main分支最新提交: $(git log main --oneline -1)"
echo ""

echo "=========================================="
echo "GitHub问题分析"
echo "=========================================="
echo ""
echo "根据您的截图:"
echo "- GitHub当前显示: archive-bridge-stub 分支"
echo "- 这是一个归档分支，可能是空的或旧的"
echo "- 您的代码在: main 分支"
echo ""
echo "解决方案:"
echo "1. 在GitHub网页点击分支下拉菜单"
echo "2. 选择 '主要的' (main) 分支"
echo "3. 或直接访问: https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/tree/main"
echo ""

echo "=========================================="
echo "推送更改到main分支"
echo "=========================================="
echo ""

# 检查是否有未提交的更改
if [[ -n $(git status -s) ]]; then
    echo "⚠️  有未提交的更改:"
    git status -s
    echo ""
    echo "是否要提交并推送到main? (需要手动确认)"
    echo "  bash 提交清理和所有更改.sh"
else
    echo "✅ 工作区干净，可以直接推送"
    echo ""
    echo "推送main分支到GitHub:"
    echo "  git push origin main"
fi

