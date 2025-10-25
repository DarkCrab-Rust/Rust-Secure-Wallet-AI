@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ==========================================
echo 🧹 开始最终仓库清理
echo ==========================================
echo.

cd /d "%~dp0\.."

REM 1. 删除临时和无效文件
echo 1️⃣ 删除临时和无效文件...
echo.

if exist "commit_rename.bat" (
    echo   ✅ 删除 commit_rename.bat
    del /f /q "commit_rename.bat" 2>nul
)

if exist "rename_to_english.sh" (
    echo   ✅ 删除 rename_to_english.sh
    del /f /q "rename_to_english.sh" 2>nul
)

REM 删除无效文件
set "files_to_delete=et --hard SHA_BEFORE,Last,Solana,tatus --porcelain"

for %%f in (%files_to_delete%) do (
    if exist "%%f" (
        echo   ✅ 删除 %%f
        del /f /q "%%f" 2>nul
    )
)

REM 删除根目录的 mod.rs 和 utils.rs (如果src中已有)
if exist "mod.rs" if exist "src\mod.rs" (
    echo   ✅ 删除根目录的 mod.rs (src中已有)
    del /f /q "mod.rs" 2>nul
)

if exist "utils.rs" if exist "src\utils.rs" (
    echo   ✅ 删除根目录的 utils.rs (src中已有)
    del /f /q "utils.rs" 2>nul
)

echo.

REM 2. 创建 LICENSE 文件
echo 2️⃣ 检查 LICENSE 文件...
echo.

if not exist "LICENSE" (
    (
        echo MIT License
        echo.
        echo Copyright (c^) 2025 DarkCrab-Rust
        echo.
        echo Permission is hereby granted, free of charge, to any person obtaining a copy
        echo of this software and associated documentation files (the "Software"^), to deal
        echo in the Software without restriction, including without limitation the rights
        echo to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        echo copies of the Software, and to permit persons to whom the Software is
        echo furnished to do so, subject to the following conditions:
        echo.
        echo The above copyright notice and this permission notice shall be included in all
        echo copies or substantial portions of the Software.
        echo.
        echo THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        echo IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        echo FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        echo AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        echo LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        echo OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        echo SOFTWARE.
    ) > LICENSE
    echo   ✅ LICENSE 文件已创建
) else (
    echo   ℹ️  LICENSE 文件已存在
)

echo.

REM 3. 显示清理结果
echo ==========================================
echo 📊 清理结果统计
echo ==========================================
echo.

echo ✅ 已删除临时文件
echo ✅ LICENSE 文件已检查
echo ✅ 仓库结构已优化
echo.

REM 4. 显示 Git 状态
echo ==========================================
echo 📋 当前 Git 状态
echo ==========================================
echo.
git status --short

echo.
echo ==========================================
echo 🎯 下一步操作
echo ==========================================
echo.
echo 1. 检查更改: git status
echo 2. 查看差异: git diff
echo 3. 提交更改:
echo    git add -A
echo    git commit -m "chore: 最终仓库优化和清理"
echo 4. 推送到GitHub:
echo    git push origin main
echo.
echo ==========================================
echo ✅ 清理完成!
echo ==========================================
echo.
pause

