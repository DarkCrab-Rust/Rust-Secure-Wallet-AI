#!/bin/bash

# 📋 列出所有可用脚本

clear

echo "=========================================="
echo "📋 DeFi热钱包 - 可用脚本列表"
echo "=========================================="
echo ""
echo "📂 项目目录: $(pwd)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 主菜单"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  bash wallet_tools.sh"
echo "  └─ 交互式菜单,访问所有工具"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 服务器管理"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  bash start_server.sh"
echo "  └─ 启动服务器 (前台运行,查看实时日志)"
echo ""
echo "  bash restart_server.sh"
echo "  └─ 重启服务器 (后台运行,自动验证)"
echo ""
echo "  bash manage_server.sh"
echo "  └─ 管理服务器 (查看状态/停止/重启指令/测试日志)"
echo ""
echo "  bash view_server_logs.sh"
echo "  └─ 查看服务器日志 (最新/实时/搜索/列表)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 测试工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  bash quick_test.sh"
echo "  └─ 快速测试 (1次完整测试,6项API)"
echo ""
echo "  bash start_and_test.sh ⭐推荐"
echo "  └─ 启动并测试 (一键完成所有操作)"
echo ""
echo "  bash week_automated_test_final.sh"
echo "  └─ 7天自动化测试 (336轮,每30分钟)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛠️  维护工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  bash cleanup_repo.sh"
echo "  └─ 清理仓库 (备份/IDE/数据库/构建产物)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  cat QUICK_START.md"
echo "  └─ 快速开始指南"
echo ""
echo "  cat SCRIPTS_REFERENCE.md"
echo "  └─ 脚本详细参考"
echo ""
echo "  cat startup-and-testing-guide.md"
echo "  └─ 完整启动和测试指南"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 推荐使用"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  新手:    bash wallet_tools.sh"
echo "  日常:    bash start_and_test.sh"
echo "  调试:    bash view_server_logs.sh"
echo "  测试:    bash quick_test.sh"
echo ""

echo "=========================================="
echo ""

# 检查脚本是否存在
echo "🔍 检查脚本文件..."
echo ""

SCRIPTS=(
    "wallet_tools.sh"
    "start_server.sh"
    "restart_server.sh"
    "manage_server.sh"
    "view_server_logs.sh"
    "quick_test.sh"
    "start_and_test.sh"
    "week_automated_test_final.sh"
    "cleanup_repo.sh"
)

ALL_EXIST=true

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "  ✅ $script"
    else
        echo "  ❌ $script (缺失)"
        ALL_EXIST=false
    fi
done

echo ""

if $ALL_EXIST; then
    echo "✅ 所有脚本文件完整!"
else
    echo "⚠️  部分脚本文件缺失"
fi

echo ""
echo "=========================================="
echo ""

