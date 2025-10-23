@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo Commit and Push New Reports
echo ==========================================
echo.

echo Step 1: Check git status...
git status --short
echo.

echo Step 2: Add all new files...
git add .
echo.

echo Step 3: Commit changes...
git commit -m "Add comprehensive code analysis report and documentation"
echo.

echo Step 4: Check current branch...
git branch --show-current
echo.

echo Step 5: Push to main branch...
git push origin main
echo.

echo ==========================================
echo Done!
echo ==========================================
echo.

pause

