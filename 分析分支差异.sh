#!/bin/bash
# 分析main分支和archive-bridge-stub分支的差异

cd "$(dirname "$0")"

echo "=========================================="
echo "分析分支差异"
echo "=========================================="
echo ""

echo "[1/6] 获取所有远程分支信息..."
git fetch origin
echo "✅ 完成"
echo ""

echo "[2/6] 检查分支存在性..."
if git show-ref --verify --quiet refs/remotes/origin/archive-bridge-stub; then
    echo "✅ archive-bridge-stub 分支存在"
else
    echo "❌ archive-bridge-stub 分支不存在"
    exit 1
fi

if git show-ref --verify --quiet refs/remotes/origin/main; then
    echo "✅ main 分支存在"
else
    echo "❌ main 分支不存在"
    exit 1
fi
echo ""

echo "[3/6] 比较提交历史..."
echo "main分支最新5个提交:"
git log origin/main --oneline -5
echo ""

echo "archive-bridge-stub分支最新5个提交:"
git log origin/archive-bridge-stub --oneline -5
echo ""

echo "[4/6] 分析分支差异..."
MAIN_AHEAD=$(git rev-list --count origin/archive-bridge-stub..origin/main)
STUB_AHEAD=$(git rev-list --count origin/main..origin/archive-bridge-stub)

echo "main分支领先archive-bridge-stub: $MAIN_AHEAD 个提交"
echo "archive-bridge-stub分支领先main: $STUB_AHEAD 个提交"
echo ""

echo "[5/6] 比较文件结构..."
echo "main分支文件数:"
MAIN_FILES=$(git ls-tree -r origin/main --name-only | wc -l)
echo "$MAIN_FILES"

echo "archive-bridge-stub分支文件数:"
STUB_FILES=$(git ls-tree -r origin/archive-bridge-stub --name-only | wc -l)
echo "$STUB_FILES"
echo ""

echo "[6/6] 显示关键文件差异..."
echo "main分支的关键文件:"
git ls-tree -r origin/main --name-only | grep -E "(Cargo.toml|README.md|src/)" | head -10
echo ""

echo "archive-bridge-stub分支的关键文件:"
git ls-tree -r origin/archive-bridge-stub --name-only | grep -E "(Cargo.toml|README.md|src/)" | head -10
echo ""

echo "=========================================="
echo "分支分析报告"
echo "=========================================="
echo ""
echo "分支对比:"
echo "- main分支: $MAIN_FILES 个文件, 领先 $MAIN_AHEAD 个提交"
echo "- archive-bridge-stub分支: $STUB_FILES 个文件, 领先 $STUB_AHEAD 个提交"
echo ""

if [ $MAIN_AHEAD -gt $STUB_AHEAD ]; then
    echo "📊 分析结果:"
    echo "✅ main分支更新，包含更多提交"
    echo "✅ 建议使用main分支作为主分支"
    echo ""
    echo "操作建议:"
    echo "1. 继续在main分支上开发"
    echo "2. 如果需要archive-bridge-stub的功能，考虑合并"
    echo "3. 设置main为默认分支"
elif [ $STUB_AHEAD -gt $MAIN_AHEAD ]; then
    echo "📊 分析结果:"
    echo "⚠️  archive-bridge-stub分支更新"
    echo "⚠️  可能需要合并或切换分支"
    echo ""
    echo "操作建议:"
    echo "1. 检查archive-bridge-stub分支的内容"
    echo "2. 决定是否需要合并两个分支"
    echo "3. 或者切换到archive-bridge-stub分支"
else
    echo "📊 分析结果:"
    echo "⚠️  两个分支分歧较大"
    echo "⚠️  需要决定保留哪个分支"
    echo ""
    echo "操作建议:"
    echo "1. 检查两个分支的功能差异"
    echo "2. 决定主分支"
    echo "3. 合并或删除不需要的分支"
fi

echo ""
echo "=========================================="
echo "详细检查命令"
echo "=========================================="
echo ""
echo "查看main分支内容:"
echo "  git checkout main"
echo "  ls -la"
echo ""
echo "查看archive-bridge-stub分支内容:"
echo "  git checkout archive-bridge-stub"
echo "  ls -la"
echo ""
echo "比较两个分支的文件差异:"
echo "  git diff --name-status origin/main origin/archive-bridge-stub"
echo ""

