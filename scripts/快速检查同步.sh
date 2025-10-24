#!/bin/bash
# 快速检查GitHub和本地代码同步状态

cd "$(dirname "$0")"

echo "🔍 快速检查GitHub main分支和本地代码..."
echo ""

# 获取远程信息
git fetch origin main 2>/dev/null

# 当前分支
BRANCH=$(git branch --show-current)
echo "📍 当前分支: $BRANCH"

# 比较提交
BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
UNCOMMITTED=$(git status -s | wc -l)

echo ""
echo "📊 同步状态:"
echo "   本地落后GitHub: $BEHIND 个提交"
echo "   本地领先GitHub: $AHEAD 个提交"
echo "   未提交文件: $UNCOMMITTED 个"
echo ""

# 判断状态
if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ] && [ $UNCOMMITTED -eq 0 ]; then
    echo "✅ 完美同步！本地和GitHub完全一致！"
elif [ $BEHIND -gt 0 ]; then
    echo "⬇️  需要拉取: git pull origin main"
elif [ $AHEAD -gt 0 ] || [ $UNCOMMITTED -gt 0 ]; then
    echo "⬆️  需要推送: bash 提交清理和所有更改.sh"
fi

echo ""
echo "📝 详细报告: bash 对比GitHub和本地代码.sh"

