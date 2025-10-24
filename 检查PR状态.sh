#!/bin/bash
# 检查GitHub仓库的所有PR状态

cd "$(dirname "$0")"

echo "=========================================="
echo "检查GitHub PR状态"
echo "=========================================="
echo ""

REPO="Yinhang3377/Rust-Blockchain-Secure-Wallet"

echo "仓库: $REPO"
echo ""

echo "[1/3] 检查本地Git状态..."
git status --short | head -10
echo ""

echo "[2/3] 检查本地分支..."
echo "当前分支:"
git branch --show-current
echo ""
echo "所有分支:"
git branch -a | head -20
echo ""

echo "[3/3] 检查最近的提交..."
git log --oneline -10
echo ""

echo "=========================================="
echo "GitHub PR 状态说明"
echo "=========================================="
echo ""
echo "根据您的截图:"
echo "✅ 总PR数: 3"
echo "✅ 开放PR数: 0"
echo "✅ 已关闭/合并: 3"
echo ""
echo "这意味着您的3个PR都已经被处理了（合并或关闭）"
echo ""

echo "=========================================="
echo "如何查看已关闭的PR"
echo "=========================================="
echo ""
echo "方法1: 在GitHub网页上"
echo "  1. 访问: https://github.com/$REPO/pulls"
echo "  2. 点击 '已关闭' 标签"
echo "  3. 查看所有已关闭/合并的PR"
echo ""
echo "方法2: 修改搜索筛选"
echo "  将搜索框的 'is:pr is:open' 改为:"
echo "  - 'is:pr is:closed'  (查看已关闭的)"
echo "  - 'is:pr is:merged'  (查看已合并的)"
echo "  - 'is:pr'            (查看所有PR)"
echo ""

echo "=========================================="
echo "创建新PR"
echo "=========================================="
echo ""
echo "如果您想创建新的PR，请执行:"
echo ""
echo "  bash fix_and_commit.sh"
echo ""
echo "或手动操作:"
echo "  1. 创建新分支: git checkout -b feature/new-update"
echo "  2. 提交更改: git add . && git commit -m 'your message'"
echo "  3. 推送分支: git push origin feature/new-update"
echo "  4. 在GitHub创建PR"
echo ""

