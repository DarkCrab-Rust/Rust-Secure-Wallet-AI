#!/bin/bash

echo "=========================================="
echo "统一目录和文件命名为英文"
echo "=========================================="
echo ""

cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

echo "开始重命名..."
echo ""

# 1. 重命名根目录文件
echo "1. 重命名根目录文件..."
if [ -f "Postman测试集合.json" ]; then
    git mv "Postman测试集合.json" "postman-collection.json"
    echo "✅ Postman测试集合.json → postman-collection.json"
fi

if [ -f "启动和测试指令.md" ]; then
    git mv "启动和测试指令.md" "startup-and-testing-guide.md"
    echo "✅ 启动和测试指令.md → startup-and-testing-guide.md"
fi

# 2. 重命名 scripts 目录中的中文文件
echo ""
echo "2. 重命名 scripts 目录中的文件..."

cd scripts

# 定义重命名映射
declare -A rename_map=(
    ["🔥_强制覆盖GitHub主分支.sh"]="force-overwrite-github-main.sh"
    ["修复环境变量.bat"]="fix-env-vars.bat"
    ["修复端口冲突.sh"]="fix-port-conflict.sh"
    ["停止并重启自动化测试.sh"]="stop-and-restart-auto-test.sh"
    ["最终验证测试.bat"]="final-verification-test.bat"
    ["分析分支差异.sh"]="analyze-branch-diff.sh"
    ["切换到新仓库.sh"]="switch-to-new-repo.sh"
    ["删除所有无用分支.sh"]="delete-useless-branches.sh"
    ["启动并测试.sh"]="start-and-test.sh"
    ["安全启动服务器.bat"]="secure-start-server.bat"
    ["完整检查仓库.sh"]="complete-repo-check.sh"
    ["对比GitHub和本地代码.sh"]="compare-github-local.sh"
    ["快速启动测试网.sh"]="quick-start-testnet.sh"
    ["快速检查同步.sh"]="quick-check-sync.sh"
    ["快速测试API.sh"]="quick-test-api.sh"
    ["快速测试Day2修复.sh"]="quick-test-day2-fix.sh"
    ["快速测试修复.bat"]="quick-test-fix.bat"
    ["提交清理和所有更改.sh"]="commit-cleanup-all.sh"
    ["查看测试日志.bat"]="view-test-logs.bat"
    ["检查PR状态.sh"]="check-pr-status.sh"
    ["检查并切换到main分支.sh"]="check-switch-main.sh"
    ["检查服务器状态.sh"]="check-server-status.sh"
    ["检查本地PR分支.sh"]="check-local-pr-branches.sh"
    ["测试创建钱包.bat"]="test-create-wallet.bat"
    ["测试环境启动.bat"]="test-env-start.bat"
    ["清理端口并启动服务器.sh"]="cleanup-port-start-server.sh"
    ["简单启动测试.sh"]="simple-start-test.sh"
    ["解决端口冲突.bat"]="resolve-port-conflict.bat"
    ["调试失败测试.bat"]="debug-failed-tests.bat"
    ["验证修复效果.bat"]="verify-fix-effect.bat"
    ["验证服务器运行状态.sh"]="verify-server-status.sh"
)

# 执行重命名
for old_name in "${!rename_map[@]}"; do
    new_name="${rename_map[$old_name]}"
    if [ -f "$old_name" ]; then
        git mv "$old_name" "$new_name" 2>/dev/null || mv "$old_name" "$new_name"
        echo "✅ $old_name → $new_name"
    fi
done

cd ..

echo ""
echo "=========================================="
echo "重命名完成！"
echo "=========================================="

echo ""
echo "当前状态:"
git status --short

echo ""
echo "=========================================="
echo "建议的后续步骤:"
echo "1. 检查重命名结果: git status"
echo "2. 提交更改: git commit -m 'chore: 统一文件命名为英文'"
echo "3. 推送: git push origin main"
echo "=========================================="

