@echo off
chcp 65001 >nul
echo 🚀 重新启动测试网 - Day 2
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cd /d "%~dp0"

echo Step 1: 停止可能运行的服务器进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    echo 发现进程 %%a 占用8080端口，正在停止...
    taskkill /F /PID %%a >nul 2>&1
)

echo Step 2: 清理编译缓存...
if exist "defi-target\debug\hot_wallet.exe" del /f "defi-target\debug\hot_wallet.exe" >nul 2>&1
if exist "target\debug\hot_wallet.exe" del /f "target\debug\hot_wallet.exe" >nul 2>&1

echo Step 3: 重新编译项目...
cargo build --release

if %errorlevel% equ 0 (
    echo ✅ 编译成功！
    echo.
    echo Step 4: 启动测试网服务器...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 服务器将在后台启动，请稍等...
    
    start /b "Testnet Server" cmd /c "start_testnet.sh"
    
    echo 等待服务器启动...
    timeout /t 10 /nobreak >nul
    
    echo.
    echo Step 5: 验证服务器状态...
    curl -s http://localhost:8080/health >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ 服务器启动成功！
    ) else (
        echo ⚠️ 服务器可能还在启动中...
    )
    
    echo.
    echo 🎉 测试网重新启动完成！
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 服务器地址: http://localhost:8080
    echo API文档: http://localhost:8080/docs
    echo 健康检查: http://localhost:8080/health
    echo.
    echo 现在可以运行自动化测试了！
    echo.
    echo 按任意键启动1周自动化测试...
    pause >nul
    
    echo.
    echo 🤖 启动1周自动化测试...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 自动化测试将在后台运行，包含以下功能：
    echo   - 健康检查
    echo   - 钱包创建和管理
    echo   - 余额查询
    echo   - 交易历史查询
    echo   - 网络状态检查
    echo.
    echo 测试间隔: 30分钟
    echo 测试时长: 7天
    echo 日志文件: logs\week_test\
    echo.
    echo 按 Ctrl+C 可以停止自动化测试
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    start /b "Automated Test" cmd /c "week_automated_test.sh"
    
    echo 自动化测试已在后台启动！
    echo 查看日志: logs\week_test\ 目录
    
) else (
    echo ❌ 编译失败！请检查错误信息
    pause
    exit /b 1
)

echo.
echo 🎉 测试网1周自动化测试已启动！
echo 服务器和自动化测试都在后台运行
echo 按任意键退出...
pause >nul
