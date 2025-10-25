@echo off
chcp 65001 >nul
echo ==========================================
echo 上传代码到GitHub (以本地为准)
echo ==========================================
echo.

cd /d "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

REM 1. 查看状态
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. 查看当前Git状态
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

git status

echo.
set /p continue="是否继续上传? (y/n): "
if /i not "%continue%"=="y" (
    echo 已取消
    pause
    exit /b
)

REM 2. 添加所有更改
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 2. 添加所有更改
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

git add -A

echo 已添加所有更改
echo.

REM 3. 查看将要提交的内容
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 3. 将要提交的内容
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

git status

echo.
set /p confirm_commit="确认提交? (y/n): "
if /i not "%confirm_commit%"=="y" (
    echo 已取消
    git reset
    pause
    exit /b
)

REM 4. 提交更改
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 4. 提交更改
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

git commit -m "chore: 清理后端目录并更新CORS配置" -m "- 删除前端相关文件和临时目录" -m "- 更新CORS支持多源(3000和3010端口)" -m "- 清理旧日志文件(保留最新3个)" -m "- 清理构建产物和重复目录" -m "- 所有核心代码和功能完整" -m "- 通过完整性检查(100%%)"

if errorlevel 1 (
    echo 提交失败
    pause
    exit /b 1
)

echo 提交成功
echo.

REM 5. 推送到GitHub
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 5. 推送到GitHub
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo 警告: 将以本地代码为准,强制推送到远程仓库
echo       这会覆盖远程仓库的内容!
echo.
set /p confirm_push="确认强制推送? (y/n): "
if /i not "%confirm_push%"=="y" (
    echo 已取消推送
    echo 提交已保存在本地,可以稍后手动推送
    pause
    exit /b
)

echo.
echo 正在推送...
echo.

git push origin main --force-with-lease

if errorlevel 1 (
    echo.
    echo 推送失败
    echo.
    echo 可能的原因:
    echo 1. 网络问题
    echo 2. 没有推送权限
    echo 3. 远程仓库有新的提交
    echo.
    echo 建议:
    echo 1. 检查网络连接
    echo 2. 确认GitHub凭据
    echo 3. 如果确定要覆盖远程,使用: git push origin main --force
    pause
    exit /b 1
)

echo.
echo ==========================================
echo 上传完成!
echo ==========================================
echo.
echo 本地代码已成功推送到GitHub!
echo.

REM 6. 显示最近提交
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 最近的提交:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

git log --oneline -5

echo.
pause

