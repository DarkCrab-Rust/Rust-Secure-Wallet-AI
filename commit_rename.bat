@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo 提交文件重命名更改
echo ==========================================
echo.

echo 1. 添加所有更改到暂存区...
git add -A

echo.
echo 2. 查看状态...
git status

echo.
echo 3. 提交更改...
git commit -m "chore: 统一文件和脚本命名为英文"

echo.
echo 4. 推送到GitHub...
git push origin main

echo.
echo ==========================================
echo 完成！
echo ==========================================
pause

