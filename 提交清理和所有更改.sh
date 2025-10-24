#!/bin/bash
# 提交文件清理和所有更改

cd "$(dirname "$0")"

echo "=========================================="
echo "提交文件清理和所有更改"
echo "=========================================="
echo ""

echo "[1/6] 检查当前状态..."
git status --short | head -50
echo ""

CHANGED_FILES=$(git status --short | wc -l)
echo "修改的文件数: $CHANGED_FILES"
echo ""

if [ $CHANGED_FILES -eq 0 ]; then
    echo "✅ 没有需要提交的更改"
    exit 0
fi

echo "[2/6] 添加所有文件..."
git add .
echo "✅ 文件已添加"
echo ""

echo "[3/6] 显示将要提交的文件..."
git diff --name-only --cached | head -50
echo ""
COMMIT_COUNT=$(git diff --name-only --cached | wc -l)
echo "将要提交: $COMMIT_COUNT 个文件"
echo ""

echo "[4/6] 创建提交..."
git commit -m "chore: 清理项目文件 + 添加完整文档和工具

文件清理:
- 删除25个无用文件
  * 7个Git命令残留
  * 11个PowerShell/批处理文件
  * 4个临时/测试文件
  * 2个备份patch文件
  * 3个误放的源代码文件

代码修复:
- 修复test_wallet_persistence测试
- 添加util::set_test_env()初始化

新增文档:
- 📊_代码功能和级别分析报告.md (1035行)
  * 13个模块完整分析
  * 企业级钱包定位 (9.2/10)
  * 8大安全特性详解
- 🔧_彻底解决PowerShell编码问题.md
- 安装GitHub_CLI查看PR.md
- ✅_文件清理完成.md
- 15+操作指南文档

新增工具:
- 完整检查仓库.sh
- fix_and_commit.sh
- commit_and_push.sh
- 检查PR状态.sh
- 检查本地PR分支.sh
- START_HERE.txt

技术改进:
✅ 彻底解决PowerShell编码问题
✅ 全部改用Git Bash和.sh脚本
✅ 测试环境正确初始化
✅ 项目目录结构清晰
✅ 432/433核心测试通过
✅ 完善的文档体系"

if [ $? -eq 0 ]; then
    echo "✅ 提交成功"
else
    echo "ℹ️  提交失败或没有新内容"
    git status
    exit 1
fi
echo ""

echo "[5/6] 检查当前分支..."
BRANCH=$(git branch --show-current)
echo "当前分支: $BRANCH"
echo ""

echo "[6/6] 推送到GitHub..."
git push origin $BRANCH

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 成功推送到GitHub!"
    echo "=========================================="
    echo ""
    echo "提交摘要:"
    echo "- 删除25个无用文件"
    echo "- 修复test_wallet_persistence测试"
    echo "- 添加完整代码分析报告 (1035行)"
    echo "- 添加15+文档文件"
    echo "- 添加6个工具脚本"
    echo "- 解决PowerShell编码问题"
    echo ""
    echo "查看仓库:"
    echo "https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ 推送失败!"
    echo "=========================================="
    echo ""
    echo "可能的原因:"
    echo "1. 网络连接问题"
    echo "2. 需要先拉取远程更改"
    echo ""
    echo "尝试:"
    echo "  git pull origin $BRANCH --rebase"
    echo "  git push origin $BRANCH"
    echo ""
    exit 1
fi

