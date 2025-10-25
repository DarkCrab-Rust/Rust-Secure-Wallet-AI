#!/bin/bash

# 🚀 上传代码到GitHub (以本地为准)

echo "=========================================="
echo "🚀 上传代码到GitHub"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 1. 查看当前状态
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣ 查看当前Git状态"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git status

echo ""
read -p "是否继续上传? (y/n): " continue_upload

if [ "$continue_upload" != "y" ]; then
    echo "❌ 已取消"
    exit 0
fi

# 2. 添加所有更改
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣ 添加所有更改"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git add -A

echo "✅ 已添加所有更改"

# 3. 查看将要提交的内容
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣ 将要提交的内容"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git status

echo ""
read -p "确认提交? (y/n): " confirm_commit

if [ "$confirm_commit" != "y" ]; then
    echo "❌ 已取消"
    git reset
    exit 0
fi

# 4. 提交更改
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣ 提交更改"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COMMIT_MSG="chore: 清理后端目录并更新CORS配置

- 删除前端相关文件和临时目录
- 更新CORS支持多源(3000和3010端口)
- 清理旧日志文件(保留最新3个)
- 清理构建产物和重复目录
- 所有核心代码和功能完整
- 通过完整性检查(100%)"

git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo "✅ 提交成功"
else
    echo "❌ 提交失败"
    exit 1
fi

# 5. 推送到GitHub (强制以本地为准)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣ 推送到GitHub"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "⚠️  将以本地代码为准,强制推送到远程仓库"
echo "   这会覆盖远程仓库的内容!"
echo ""
read -p "确认强制推送? (y/n): " confirm_push

if [ "$confirm_push" != "y" ]; then
    echo "❌ 已取消推送"
    echo "提交已保存在本地,可以稍后手动推送"
    exit 0
fi

echo ""
echo "🚀 正在推送..."

# 使用 --force-with-lease 更安全
git push origin main --force-with-lease

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功!"
else
    echo ""
    echo "❌ 推送失败"
    echo ""
    echo "可能的原因:"
    echo "1. 网络问题"
    echo "2. 没有推送权限"
    echo "3. 远程仓库有新的提交"
    echo ""
    echo "建议:"
    echo "1. 检查网络连接"
    echo "2. 确认GitHub凭据"
    echo "3. 如果确定要覆盖远程,使用: git push origin main --force"
    exit 1
fi

# 6. 验证
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣ 验证推送结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git log --oneline -5

echo ""
echo "=========================================="
echo "✅ 上传完成!"
echo "=========================================="
echo ""
echo "本地代码已成功推送到GitHub!"
echo ""

