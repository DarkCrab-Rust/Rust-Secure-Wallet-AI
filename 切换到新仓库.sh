#!/bin/bash
# 切换到新GitHub仓库

cd "$(dirname "$0")"

NEW_REPO="https://github.com/wangjunxi3344-del/Rust-Secure-Wallet-AI.git"

echo "=========================================="
echo "切换到新GitHub仓库"
echo "=========================================="
echo ""

echo "[1/6] 检查当前状态..."
BRANCH=$(git branch --show-current)
echo "当前分支: $BRANCH"
echo ""

if [ "$BRANCH" != "main" ]; then
    echo "切换到main分支..."
    git checkout main
fi

echo "[2/6] 查看当前remote..."
echo "当前remote配置:"
git remote -v
echo ""

echo "[3/6] 删除旧的origin..."
git remote remove origin 2>/dev/null || echo "origin不存在，跳过"
git remote remove old-origin 2>/dev/null || echo "old-origin不存在，跳过"
echo "✅ 完成"
echo ""

echo "[4/6] 添加新仓库..."
git remote add origin "$NEW_REPO"
echo "✅ 已添加新仓库: $NEW_REPO"
echo ""

echo "[5/6] 验证配置..."
echo "新的remote配置:"
git remote -v
echo ""

echo "[6/6] 推送代码到新仓库..."
echo "即将推送所有代码到新仓库..."
echo ""

git push origin main --force

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 成功切换到新仓库！"
    echo "=========================================="
    echo ""
    echo "新仓库地址:"
    echo "$NEW_REPO"
    echo ""
    echo "查看仓库:"
    echo "https://github.com/wangjunxi3344-del/Rust-Secure-Wallet-AI"
    echo ""
    echo "验证同步:"
    git fetch origin
    BEHIND=$(git rev-list --count HEAD..origin/main)
    AHEAD=$(git rev-list --count origin/main..HEAD)
    echo "本地落后: $BEHIND 个提交"
    echo "本地领先: $AHEAD 个提交"
    
    if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ]; then
        echo ""
        echo "✅ 完美同步！"
    fi
else
    echo ""
    echo "=========================================="
    echo "❌ 推送失败"
    echo "=========================================="
    echo ""
    echo "请检查:"
    echo "1. 网络连接"
    echo "2. GitHub认证信息"
    echo "3. 仓库访问权限"
    exit 1
fi

echo ""
echo "=========================================="
echo "完成！"
echo "=========================================="

