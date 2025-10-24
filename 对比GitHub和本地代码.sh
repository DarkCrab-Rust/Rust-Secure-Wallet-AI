#!/bin/bash
# 对比GitHub main分支和本地代码的一致性

cd "$(dirname "$0")"

echo "=========================================="
echo "对比GitHub main分支和本地代码"
echo "=========================================="
echo ""

echo "[1/10] 检查当前分支..."
CURRENT_BRANCH=$(git branch --show-current)
echo "当前本地分支: $CURRENT_BRANCH"
echo ""

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  不在main分支，切换到main..."
    git checkout main
    if [ $? -ne 0 ]; then
        echo "❌ 切换失败"
        exit 1
    fi
    echo "✅ 已切换到main分支"
    echo ""
fi

echo "[2/10] 获取最新远程信息..."
git fetch origin
if [ $? -eq 0 ]; then
    echo "✅ 成功获取远程信息"
else
    echo "❌ 无法连接到GitHub，请检查网络"
    exit 1
fi
echo ""

echo "[3/10] 查看本地main分支最新提交..."
echo "本地main分支最近5个提交:"
git log main --oneline --decorate -5
echo ""

echo "[4/10] 查看远程main分支最新提交..."
echo "GitHub main分支最近5个提交:"
git log origin/main --oneline --decorate -5
echo ""

echo "[5/10] 比较本地和远程的差异..."
echo ""

# 检查本地是否落后远程
BEHIND=$(git rev-list --count HEAD..origin/main)
echo "本地落后GitHub: $BEHIND 个提交"

# 检查本地是否领先远程
AHEAD=$(git rev-list --count origin/main..HEAD)
echo "本地领先GitHub: $AHEAD 个提交"
echo ""

if [ $BEHIND -gt 0 ]; then
    echo "⚠️  GitHub有新提交，本地还没有:"
    git log HEAD..origin/main --oneline --decorate
    echo ""
fi

if [ $AHEAD -gt 0 ]; then
    echo "📤 本地有新提交，还没推送到GitHub:"
    git log origin/main..HEAD --oneline --decorate
    echo ""
fi

echo "[6/10] 检查工作区状态..."
if [[ -n $(git status -s) ]]; then
    echo "⚠️  有未提交的更改:"
    git status -s
    echo ""
    UNCOMMITTED=$(git status -s | wc -l)
    echo "未提交的文件数: $UNCOMMITTED"
else
    echo "✅ 工作区干净，没有未提交的更改"
fi
echo ""

echo "[7/10] 检查文件差异..."
if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ]; then
    echo "✅ 本地和GitHub完全同步！"
else
    echo "文件差异列表:"
    if [ $BEHIND -gt 0 ]; then
        echo ""
        echo "GitHub上有但本地没有的更改:"
        git diff --name-status HEAD..origin/main
    fi
    if [ $AHEAD -gt 0 ]; then
        echo ""
        echo "本地有但GitHub上没有的更改:"
        git diff --name-status origin/main..HEAD
    fi
fi
echo ""

echo "[8/10] 检查关键文件是否存在..."
echo ""
echo "检查核心文件:"
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ $1 (缺失)"
    fi
}

check_file "Cargo.toml"
check_file "README.md"
check_file "src/main.rs"
check_file "src/lib.rs"
check_file "src/core/mod.rs"
check_file "tests/core_wallet_manager_tests.rs"
echo ""

echo "[9/10] 统计文件数量..."
echo ""
LOCAL_FILES=$(git ls-files | wc -l)
echo "本地跟踪的文件数: $LOCAL_FILES"

REMOTE_FILES=$(git ls-tree -r origin/main --name-only | wc -l)
echo "GitHub上的文件数: $REMOTE_FILES"

if [ $LOCAL_FILES -eq $REMOTE_FILES ]; then
    echo "✅ 文件数量一致"
else
    DIFF=$((LOCAL_FILES - REMOTE_FILES))
    if [ $DIFF -gt 0 ]; then
        echo "⚠️  本地比GitHub多 $DIFF 个文件"
    else
        echo "⚠️  本地比GitHub少 ${DIFF#-} 个文件"
    fi
fi
echo ""

echo "[10/10] 生成对比报告..."
echo ""

echo "=========================================="
echo "一致性检查报告"
echo "=========================================="
echo ""
echo "仓库URL: https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet"
echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "分支信息:"
echo "- 本地分支: $CURRENT_BRANCH"
echo "- 本地commit: $(git rev-parse --short HEAD)"
echo "- 远程commit: $(git rev-parse --short origin/main)"
echo ""
echo "同步状态:"
echo "- 本地落后: $BEHIND 个提交"
echo "- 本地领先: $AHEAD 个提交"
echo "- 未提交更改: ${UNCOMMITTED:-0} 个文件"
echo ""
echo "文件统计:"
echo "- 本地文件: $LOCAL_FILES"
echo "- GitHub文件: $REMOTE_FILES"
echo ""

if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ] && [ -z "$(git status -s)" ]; then
    echo "✅✅✅ 完美同步！ ✅✅✅"
    echo ""
    echo "本地代码和GitHub main分支完全一致！"
    echo ""
elif [ $BEHIND -gt 0 ]; then
    echo "⚠️  需要从GitHub拉取更新"
    echo ""
    echo "执行以下命令更新:"
    echo "  git pull origin main"
    echo ""
elif [ $AHEAD -gt 0 ]; then
    echo "📤 需要推送到GitHub"
    echo ""
    echo "执行以下命令推送:"
    echo "  git push origin main"
    echo ""
    echo "或使用脚本:"
    echo "  bash 提交清理和所有更改.sh"
    echo ""
else
    echo "⚠️  有本地未提交的更改"
    echo ""
    echo "执行以下命令提交并推送:"
    echo "  bash 提交清理和所有更改.sh"
    echo ""
fi

echo "=========================================="
echo "完成！"
echo "=========================================="

