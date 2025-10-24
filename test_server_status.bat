@echo off
chcp 65001 >nul
echo 检查测试网服务器状态...
echo.

cd /d "%~dp0"

echo 检查8080端口是否被占用...
netstat -ano | findstr :8080
if %errorlevel% equ 0 (
    echo ✅ 服务器正在运行
) else (
    echo ❌ 服务器未运行
)

echo.
echo 测试健康检查端点...
curl -s http://localhost:8080/health
if %errorlevel% equ 0 (
    echo ✅ 健康检查成功
) else (
    echo ❌ 健康检查失败
)

echo.
echo 测试API端点...
curl -s -H "Authorization: Bearer test-api-key-12345" http://localhost:8080/wallets
if %errorlevel% equ 0 (
    echo ✅ API端点正常
) else (
    echo ❌ API端点异常
)

echo.
pause
