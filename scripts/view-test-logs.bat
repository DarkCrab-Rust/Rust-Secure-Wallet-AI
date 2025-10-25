@echo off
echo 📋 查看测试日志
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if exist "logs\week_test\automated_test_20251025_024740.log" (
    echo 找到日志文件，显示内容：
    echo.
    type "logs\week_test\automated_test_20251025_024740.log"
) else (
    echo 日志文件不存在，列出可用的日志文件：
    dir logs\week_test\*.log
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pause
