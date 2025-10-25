#!/bin/bash

# 📋 查看服务器日志

echo "=========================================="
echo "📋 DeFi热钱包 - 服务器日志查看器"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# 检查日志目录
if [ ! -d "logs" ]; then
    echo "❌ 日志目录不存在"
    echo ""
    echo "提示: 使用 start_and_test.sh 或 restart_server.sh 启动服务器会自动创建日志"
    exit 1
fi

# 查找最新的服务器日志
LATEST_LOG=$(ls -t logs/server_*.log 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
    echo "❌ 未找到服务器日志文件"
    echo ""
    echo "提示: 使用 start_and_test.sh 或 restart_server.sh 启动服务器会自动创建日志"
    exit 1
fi

echo "📝 日志文件: $LATEST_LOG"
echo "📅 修改时间: $(stat -c %y "$LATEST_LOG" 2>/dev/null || stat -f "%Sm" "$LATEST_LOG" 2>/dev/null)"
echo ""

while true; do
    echo "请选择操作:"
    echo ""
    echo "1. 查看最后20行"
    echo "2. 查看最后50行"
    echo "3. 查看最后100行"
    echo "4. 查看全部日志"
    echo "5. 实时跟踪日志 (tail -f)"
    echo "6. 搜索日志内容"
    echo "7. 查看所有日志文件列表"
    echo "8. 退出"
    echo ""
    read -p "请输入选项 (1-8): " choice

    case $choice in
        1)
            echo ""
            echo "=========================================="
            echo "最后20行日志"
            echo "=========================================="
            echo ""
            tail -20 "$LATEST_LOG"
            echo ""
            read -p "按Enter继续..."
            ;;
        2)
            echo ""
            echo "=========================================="
            echo "最后50行日志"
            echo "=========================================="
            echo ""
            tail -50 "$LATEST_LOG"
            echo ""
            read -p "按Enter继续..."
            ;;
        3)
            echo ""
            echo "=========================================="
            echo "最后100行日志"
            echo "=========================================="
            echo ""
            tail -100 "$LATEST_LOG"
            echo ""
            read -p "按Enter继续..."
            ;;
        4)
            echo ""
            echo "=========================================="
            echo "全部日志"
            echo "=========================================="
            echo ""
            cat "$LATEST_LOG"
            echo ""
            read -p "按Enter继续..."
            ;;
        5)
            echo ""
            echo "=========================================="
            echo "实时跟踪日志 (按 Ctrl+C 停止)"
            echo "=========================================="
            echo ""
            tail -f "$LATEST_LOG"
            ;;
        6)
            echo ""
            read -p "请输入搜索关键词: " keyword
            echo ""
            echo "=========================================="
            echo "搜索结果: $keyword"
            echo "=========================================="
            echo ""
            grep -i "$keyword" "$LATEST_LOG" || echo "未找到匹配内容"
            echo ""
            read -p "按Enter继续..."
            ;;
        7)
            echo ""
            echo "=========================================="
            echo "所有日志文件"
            echo "=========================================="
            echo ""
            ls -lh logs/server_*.log 2>/dev/null || echo "未找到日志文件"
            echo ""
            read -p "按Enter继续..."
            ;;
        8)
            echo ""
            echo "再见!"
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择"
            ;;
    esac
    
    clear
    echo "=========================================="
    echo "📋 DeFi热钱包 - 服务器日志查看器"
    echo "=========================================="
    echo ""
    echo "📝 当前日志: $LATEST_LOG"
    echo ""
done

