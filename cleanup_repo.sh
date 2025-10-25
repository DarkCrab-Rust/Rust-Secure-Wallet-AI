#!/bin/bash

echo "=========================================="
echo "仓库清理工具"
echo "=========================================="
echo ""

cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

echo "⚠️  警告: 此脚本将删除以下内容:"
echo "1. 备份目录 (.git_备份, .git_corrupt, .husky_bak)"
echo "2. IDE配置 (.vscode)"
echo "3. 数据库文件 (*.db, *.sqlite)"
echo "4. 测试产物 (proptest-regressions/, tarpaulin-report.html)"
echo "5. 日志文件 (logs/)"
echo ""

read -p "确认继续? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "已取消"
    exit 0
fi

echo ""
echo "=========================================="
echo "开始清理..."
echo "=========================================="

# 1. 删除备份目录
echo "1. 清理备份目录..."
rm -rf .git_备份 .git_corrupt .husky_bak
echo "✅ 备份目录已删除"

# 2. 删除IDE配置
echo "2. 清理IDE配置..."
rm -rf .vscode
echo "✅ IDE配置已删除"

# 3. 删除数据库文件
echo "3. 清理数据库文件..."
find . -name "*.db" -type f -delete
find . -name "*.sqlite" -type f -delete
echo "✅ 数据库文件已删除"

# 4. 删除测试产物
echo "4. 清理测试产物..."
rm -rf proptest-regressions/
rm -f tarpaulin-report.html
echo "✅ 测试产物已删除"

# 5. 清理日志
echo "5. 清理日志文件..."
rm -rf logs/
rm -f *.log
echo "✅ 日志文件已删除"

# 6. 清理构建产物
echo "6. 清理构建产物..."
rm -rf target/ defi-target/ target_test_*/
echo "✅ 构建产物已删除"

# 7. 从Git中删除已追踪的不应该提交的文件
echo "7. 从Git中移除不应该追踪的文件..."
git rm --cached -r .git_备份 2>/dev/null || true
git rm --cached -r .git_corrupt 2>/dev/null || true
git rm --cached -r .husky_bak 2>/dev/null || true
git rm --cached -r .vscode 2>/dev/null || true
git rm --cached data/*.db 2>/dev/null || true
git rm --cached *.db 2>/dev/null || true
git rm --cached -r proptest-regressions/ 2>/dev/null || true
git rm --cached tarpaulin-report.html 2>/dev/null || true
echo "✅ Git追踪已清理"

echo ""
echo "=========================================="
echo "清理完成！"
echo "=========================================="

echo ""
echo "当前状态:"
git status --short

echo ""
echo "=========================================="
echo "建议的后续步骤:"
echo "1. 检查 git status"
echo "2. 提交更改: git add .gitignore"
echo "3. 提交: git commit -m 'chore: 清理仓库并更新.gitignore'"
echo "4. 推送: git push origin main"
echo "=========================================="

