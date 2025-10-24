#!/bin/bash
# 快速检查GitHub和本地同步状态（不创建新文件）

cd "$(dirname "$0")/.."

echo "=== GitHub vs Local Sync Check ==="
echo ""

git fetch origin 2>/dev/null

BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
UNCOMMITTED=$(git status -s | wc -l)
BRANCHES=$(git branch -r | grep -v HEAD | wc -l)
LOCAL_FILES=$(git ls-files | wc -l)

echo "Sync Status:"
echo "  Behind GitHub: $BEHIND commits"
echo "  Ahead of GitHub: $AHEAD commits"
echo "  Uncommitted files: $UNCOMMITTED"
echo ""
echo "Repository Info:"
echo "  Remote branches: $BRANCHES"
echo "  Tracked files: $LOCAL_FILES"
echo ""

if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ] && [ $UNCOMMITTED -eq 0 ]; then
    echo "✅ PERFECT SYNC!"
elif [ $UNCOMMITTED -gt 0 ]; then
    echo "⚠️  Need to commit and push"
elif [ $AHEAD -gt 0 ]; then
    echo "⚠️  Need to push"
elif [ $BEHIND -gt 0 ]; then
    echo "⚠️  Need to pull"
fi

