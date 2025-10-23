@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo Checking GitHub Sync Status
echo ==========================================
echo.

echo [1] Fetching from GitHub...
git fetch origin main 2>nul
echo.

echo [2] Current branch:
git branch --show-current
echo.

echo [3] Local vs Remote comparison:
echo ==========================================
git diff --shortstat main origin/main
echo.

echo [4] File difference count:
git diff --name-only main origin/main > temp_diff.txt
for /f %%a in ('type temp_diff.txt ^| find /c /v ""') do set COUNT=%%a
echo Total different files: %COUNT%
echo.

if %COUNT% EQU 0 (
    echo ==========================================
    echo STATUS: SYNCHRONIZED
    echo Your local code matches GitHub main branch
    echo ==========================================
) else (
    echo ==========================================
    echo STATUS: NOT SYNCHRONIZED
    echo Differences found: %COUNT% files
    echo ==========================================
    echo.
    echo Different files:
    type temp_diff.txt
)

del temp_diff.txt 2>nul
echo.
pause

