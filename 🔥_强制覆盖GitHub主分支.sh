#!/bin/bash
# 强制用本地main分支覆盖GitHub的main分支

cd "$(dirname "$0")"

echo "=========================================="
echo "⚠️  强制覆盖GitHub主分支 ⚠️"
echo "=========================================="
echo ""
echo "此操作将："
echo "1. ✅ 用本地main分支完全覆盖GitHub的main分支"
echo "2. ✅ GitHub上的main分支将与本地完全一致"
echo "3. ⚠️  GitHub上main分支的历史可能被覆盖"
echo ""

# 询问确认
read -p "确定要继续吗？(输入 YES 继续): " confirm

if [ "$confirm" != "YES" ]; then
    echo "❌ 操作已取消"
    exit 1
fi

echo ""
echo "[1/8] 检查当前分支..."
CURRENT_BRANCH=$(git branch --show-current)
echo "当前分支: $CURRENT_BRANCH"
echo ""

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  不在main分支，切换到main..."
    git checkout main
    if [ $? -ne 0 ]; then
        echo "❌ 切换失败"
        exit 1
    fi
    echo "✅ 已切换到main分支"
fi
echo ""

echo "[2/8] 检查工作区状态..."
if [[ -n $(git status -s) ]]; then
    echo "⚠️  有未提交的更改，需要先提交"
    git status -s
    echo ""
    read -p "是否提交这些更改？(y/n): " commit_confirm
    if [ "$commit_confirm" = "y" ] || [ "$commit_confirm" = "Y" ]; then
        git add .
        git commit -m "chore: 提交所有更改，准备覆盖GitHub主分支"
        echo "✅ 已提交"
    else
        echo "❌ 需要先处理未提交的更改"
        exit 1
    fi
else
    echo "✅ 工作区干净"
fi
echo ""

echo "[3/8] 查看本地main分支最新提交..."
git log --oneline -5
echo ""

echo "[4/8] 获取远程信息..."
git fetch origin
echo "✅ 完成"
echo ""

echo "[5/8] 查看将要覆盖的GitHub main分支..."
echo "GitHub main分支最近5个提交:"
git log origin/main --oneline -5
echo ""

echo "[6/8] 最后确认..."
echo ""
echo "⚠️⚠️⚠️ 警告 ⚠️⚠️⚠️"
echo ""
echo "即将用本地main分支覆盖GitHub的main分支！"
echo "GitHub上的main分支历史可能会丢失！"
echo ""
read -p "最后确认，确定要覆盖吗？(输入 FORCE 继续): " final_confirm

if [ "$final_confirm" != "FORCE" ]; then
    echo "❌ 操作已取消"
    exit 1
fi

echo ""
echo "[7/8] 强制推送到GitHub main分支..."
echo "执行: git push origin main --force-with-lease"
echo ""

git push origin main --force-with-lease

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 成功覆盖GitHub main分支！"
else
    echo ""
    echo "❌ 推送失败！"
    echo ""
    echo "如果--force-with-lease失败，可以尝试更强力的推送:"
    read -p "是否使用 --force 强制推送？(输入 FORCE): " force_confirm
    if [ "$force_confirm" = "FORCE" ]; then
        git push origin main --force
        if [ $? -eq 0 ]; then
            echo "✅ 强制推送成功！"
        else
            echo "❌ 强制推送失败！"
            exit 1
        fi
    else
        echo "❌ 操作已取消"
        exit 1
    fi
fi

echo ""
echo "[8/8] 验证覆盖结果..."
git fetch origin
BEHIND=$(git rev-list --count HEAD..origin/main)
AHEAD=$(git rev-list --count origin/main..HEAD)

echo "验证结果:"
echo "- 本地落后GitHub: $BEHIND 个提交"
echo "- 本地领先GitHub: $AHEAD 个提交"

if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ]; then
    echo ""
    echo "✅✅✅ 完美覆盖！ ✅✅✅"
    echo "本地和GitHub main分支完全一致！"
else
    echo "⚠️  可能还有差异，请检查"
fi

echo ""
echo "=========================================="
echo "覆盖完成！"
echo "=========================================="
echo ""
echo "GitHub仓库链接:"
echo "https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet"
echo ""
echo "建议:"
echo "1. 访问GitHub确认main分支内容"
echo "2. 设置main为默认分支"
echo "3. 删除不需要的其他分支"
echo ""

