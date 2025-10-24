#!/bin/bash
# Commit and push new reports to GitHub

cd "$(dirname "$0")"

echo "=========================================="
echo "Commit and Push New Reports"
echo "=========================================="
echo ""

echo "[1/6] Adding all new files..."
git add .
echo "✅ Files added"
echo ""

echo "[2/6] Checking status..."
git status --short
echo ""

echo "[3/6] Files to be committed:"
git diff --name-only --cached | head -20
FILE_COUNT=$(git diff --name-only --cached | wc -l)
echo "Total: $FILE_COUNT files"
echo ""

echo "[4/6] Committing changes..."
git commit -m "docs: 添加完整代码分析报告和操作指南

- 新增代码功能和级别分析报告（1035行）
- 新增GitHub同步操作指南
- 新增脚本使用说明文档
- 新增同步检查工具
- 完善项目文档体系

此次更新包含：
✅ 13个模块的详细功能分析
✅ 企业级钱包定位说明（9.2/10）
✅ 安全特性完整梳理
✅ 适用场景和部署建议
✅ 脚本清理总结
✅ GitHub同步工具"

if [ $? -eq 0 ]; then
    echo "✅ Commit successful"
else
    echo "❌ Commit failed"
    exit 1
fi
echo ""

echo "[5/6] Checking current branch..."
BRANCH=$(git branch --show-current)
echo "Current branch: $BRANCH"
echo ""

echo "[6/6] Pushing to GitHub..."
git push origin $BRANCH

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Successfully pushed to GitHub!"
    echo "=========================================="
    echo ""
    echo "Verify at:"
    echo "https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ Push failed!"
    echo "=========================================="
    echo ""
    echo "You may need to:"
    echo "1. Check your network connection"
    echo "2. Verify GitHub credentials"
    echo "3. Pull remote changes first: git pull origin $BRANCH"
    echo ""
    exit 1
fi

