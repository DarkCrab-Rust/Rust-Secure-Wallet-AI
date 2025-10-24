#!/bin/bash
# 将所有AI生成的文件移动到ai-scripts文件夹

cd "$(dirname "$0")/.."

echo "Moving AI-generated files to ai-scripts folder..."
echo ""

# 创建子文件夹
mkdir -p ai-scripts/sync-check
mkdir -p ai-scripts/cleanup
mkdir -p ai-scripts/branch-management
mkdir -p ai-scripts/docs

# 移动同步检查相关
mv -v 快速检查同步.sh ai-scripts/sync-check/ 2>/dev/null
mv -v 对比GitHub和本地代码.sh ai-scripts/sync-check/ 2>/dev/null
mv -v final_sync_check.sh ai-scripts/sync-check/ 2>/dev/null
mv -v 完整检查仓库.sh ai-scripts/sync-check/ 2>/dev/null

# 移动清理相关
mv -v 提交清理和所有更改.sh ai-scripts/cleanup/ 2>/dev/null
mv -v commit_and_push.sh ai-scripts/cleanup/ 2>/dev/null
mv -v fix_and_commit.sh ai-scripts/cleanup/ 2>/dev/null

# 移动分支管理相关
mv -v 检查并切换到main分支.sh ai-scripts/branch-management/ 2>/dev/null
mv -v 分析分支差异.sh ai-scripts/branch-management/ 2>/dev/null
mv -v 删除所有无用分支.sh ai-scripts/branch-management/ 2>/dev/null
mv -v 检查PR状态.sh ai-scripts/branch-management/ 2>/dev/null
mv -v 检查本地PR分支.sh ai-scripts/branch-management/ 2>/dev/null

# 移动文档
mv -v *.md ai-scripts/docs/ 2>/dev/null
mv -v *.txt ai-scripts/docs/ 2>/dev/null

# 排除核心文档
mv -v ai-scripts/docs/README.md . 2>/dev/null
mv -v ai-scripts/docs/CHANGELOG.md . 2>/dev/null
mv -v ai-scripts/docs/SECURITY.md . 2>/dev/null
mv -v ai-scripts/docs/CONTRIBUTING.md . 2>/dev/null
mv -v ai-scripts/docs/ARCHIVE.md . 2>/dev/null

echo ""
echo "Done! All AI-generated files moved to ai-scripts/"
echo ""
echo "To delete all AI files:"
echo "  rm -rf ai-scripts/"

