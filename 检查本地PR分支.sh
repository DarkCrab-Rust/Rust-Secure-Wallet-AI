#!/bin/bash
# 检查本地和远程的PR相关分支

cd "$(dirname "$0")"

echo "=========================================="
echo "检查PR相关分支和合并历史"
echo "=========================================="
echo ""

echo "[1/6] 获取最新的远程信息..."
git fetch origin --prune
echo "✅ 完成"
echo ""

echo "[2/6] 查看所有远程分支..."
echo "远程分支列表:"
git branch -r | grep -v HEAD
echo ""

echo "[3/6] 查看本地分支..."
echo "本地分支列表:"
git branch -a
echo ""
echo "当前分支:"
git branch --show-current
echo ""

echo "[4/6] 查看最近的合并提交..."
echo "最近20个合并提交:"
git log --merges --oneline --decorate -20
echo ""

echo "[5/6] 查看所有分支的最近提交..."
echo "所有分支的提交历史（图形化）:"
git log --all --graph --oneline --decorate -30
echo ""

echo "[6/6] 检查main分支的提交历史..."
echo "main分支最近10个提交:"
git log origin/main --oneline -10
echo ""

echo "=========================================="
echo "分析结果"
echo "=========================================="
echo ""

# 统计分支数量
LOCAL_BRANCHES=$(git branch | wc -l)
REMOTE_BRANCHES=$(git branch -r | grep -v HEAD | wc -l)

echo "本地分支数: $LOCAL_BRANCHES"
echo "远程分支数: $REMOTE_BRANCHES"
echo ""

echo "=========================================="
echo "建议"
echo "=========================================="
echo ""
echo "1. 如果您看到类似 'feature/xxx' 或 'fix/xxx' 的远程分支，"
echo "   这些可能是PR对应的分支。"
echo ""
echo "2. 如果看到很多合并提交，说明PR已经被合并。"
echo ""
echo "3. 访问以下链接查看GitHub上的PR历史:"
echo "   https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/pulls"
echo ""

