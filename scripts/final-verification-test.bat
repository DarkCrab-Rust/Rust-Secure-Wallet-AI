@echo off
echo 🎯 最终验证测试
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set API_BASE=http://localhost:8888
set API_KEY=testnet_api_key_117ca14556c34271
set SUCCESS_COUNT=0
set FAILURE_COUNT=0

echo 测试配置:
echo   - API地址: %API_BASE%
echo   - API密钥: %API_KEY%
echo.

echo 开始最终验证测试...
echo.

REM 测试1: 健康检查
echo [%date% %time%] 测试: 健康检查
curl -s "%API_BASE%/api/health" | findstr /C:"ok" >nul
if %errorlevel% equ 0 (
    echo ✅ 健康检查 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 健康检查 - 失败
    set /a FAILURE_COUNT+=1
)

REM 测试2: 钱包列表
echo [%date% %time%] 测试: 钱包列表
curl -s -X GET "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" | findstr /C:"name" >nul
if %errorlevel% equ 0 (
    echo ✅ 钱包列表 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 钱包列表 - 失败
    set /a FAILURE_COUNT+=1
)

REM 测试3: 创建钱包
echo [%date% %time%] 测试: 创建钱包
set WALLET_NAME=final_test_wallet_%RANDOM%
curl -s -X POST "%API_BASE%/api/wallets" -H "Authorization: Bearer %API_KEY%" -H "Content-Type: application/json" -d "{\"name\": \"%WALLET_NAME%\", \"description\": \"最终测试钱包\", \"quantum_safe\": false}" | findstr /C:"address" >nul
if %errorlevel% equ 0 (
    echo ✅ 创建钱包 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 创建钱包 - 失败
    set /a FAILURE_COUNT+=1
)

REM 测试4: 余额查询
echo [%date% %time%] 测试: 余额查询
curl -s -X GET "%API_BASE%/api/wallets/%WALLET_NAME%/balance?network=eth" -H "Authorization: Bearer %API_KEY%" | findstr /C:"balance" >nul
if %errorlevel% equ 0 (
    echo ✅ 余额查询 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 余额查询 - 失败
    set /a FAILURE_COUNT+=1
)

REM 测试5: 交易历史
echo [%date% %time%] 测试: 交易历史
curl -s -X GET "%API_BASE%/api/wallets/%WALLET_NAME%/history" -H "Authorization: Bearer %API_KEY%" | findstr /C:"transactions" >nul
if %errorlevel% equ 0 (
    echo ✅ 交易历史 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 交易历史 - 失败
    set /a FAILURE_COUNT+=1
)

REM 测试6: 网络状态
echo [%date% %time%] 测试: 网络状态
curl -s -X GET "%API_BASE%/api/metrics" -H "Authorization: Bearer %API_KEY%" | findstr /C:"defi_hot_wallet" >nul
if %errorlevel% equ 0 (
    echo ✅ 网络状态 - 成功
    set /a SUCCESS_COUNT+=1
) else (
    echo ❌ 网络状态 - 失败
    set /a FAILURE_COUNT+=1
)

echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 📊 最终验证结果:
echo   成功: %SUCCESS_COUNT%
echo   失败: %FAILURE_COUNT%
echo   成功率: %SUCCESS_COUNT%/6

if %SUCCESS_COUNT% equ 6 (
    echo 🎉 所有测试通过！修复成功！
    echo 现在可以运行1周自动化测试了！
) else (
    echo ⚠️ 还有 %FAILURE_COUNT% 个测试失败，需要进一步调试
)

echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pause
