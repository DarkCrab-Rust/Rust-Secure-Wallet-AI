#!/bin/bash

# 🎯 DeFi热钱包 - 工具菜单

clear

while true; do
    echo "=========================================="
    echo "🎯 DeFi热钱包 - 工具菜单"
    echo "=========================================="
    echo ""
    echo "📂 当前目录: $(pwd)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 服务器管理"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1. 启动服务器 (后台)    (restart_server.sh)"
    echo "  2. 停止服务器"
    echo "  3. 重启服务器           (restart_server.sh)"
    echo "  4. 查看服务器状态"
    echo "  5. 查看服务器日志       (view_server_logs.sh)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧪 测试工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  6. 快速测试             (quick_test.sh)"
    echo "  7. 启动并测试           (start_and_test.sh)"
    echo "  8. 自动化测试 (可选时长) (week_automated_test_final.sh)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🛠️  维护工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  9. 清理仓库             (cleanup_repo.sh)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  0. 退出"
    echo ""
    echo "=========================================="
    read -p "请输入选项 (0-9): " choice

    case $choice in
        1)
            clear
            echo "🚀 启动服务器 (后台运行)..."
            echo ""
            bash restart_server.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        2)
            clear
            echo "🛑 停止服务器..."
            echo ""
            PID=$(netstat -ano | grep :8888 | grep LISTENING | awk '{print $5}' | head -1)
            if [ ! -z "$PID" ]; then
                echo "找到服务器进程: $PID"
                taskkill //F //PID $PID
                echo "✅ 服务器已停止"
            else
                echo "⚠️  未找到运行中的服务器"
            fi
            echo ""
            read -p "按Enter返回菜单..."
            clear
            ;;
        3)
            clear
            echo "🔄 重启服务器..."
            echo ""
            bash restart_server.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        4)
            clear
            echo "📊 查看服务器状态..."
            echo ""
            echo "检查8888端口:"
            netstat -ano | grep :8888
            echo ""
            echo "测试健康检查:"
            curl -s http://localhost:8888/api/health
            echo ""
            echo ""
            read -p "按Enter返回菜单..."
            clear
            ;;
        5)
            clear
            echo "📋 查看服务器日志..."
            echo ""
            bash view_server_logs.sh
            clear
            ;;
        6)
            clear
            echo "🧪 快速测试..."
            echo ""
            bash quick_test.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        7)
            clear
            echo "🚀 启动并测试..."
            echo ""
            bash start_and_test.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        8)
            clear
            echo "⏰ 自动化测试 (可选时长)..."
            echo ""
            bash week_automated_test_final.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        9)
            clear
            echo "🧹 清理仓库..."
            echo ""
            bash cleanup_repo.sh
            read -p "按Enter返回菜单..."
            clear
            ;;
        0)
            clear
            echo ""
            echo "👋 再见!"
            echo ""
            exit 0
            ;;
        *)
            clear
            echo ""
            echo "❌ 无效选项，请重新选择"
            echo ""
            sleep 2
            clear
            ;;
    esac
done

