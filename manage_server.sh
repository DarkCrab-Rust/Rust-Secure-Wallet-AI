#!/bin/bash

echo "=========================================="
echo "DeFi热钱包 - 服务器管理工具"
echo "=========================================="
echo ""

while true; do
    echo "请选择操作:"
    echo ""
    echo "1. 查看服务器状态"
    echo "2. 停止服务器"
    echo "3. 查看重启指令"
    echo "4. 查看测试日志"
    echo "5. 退出"
    echo ""
    read -p "请输入选项 (1-5): " choice

    case $choice in
        1)
            echo ""
            echo "=========================================="
            echo "服务器状态"
            echo "=========================================="
            echo ""
            echo "检查8888端口:"
            netstat -ano | grep :8888
            echo ""
            echo "测试健康检查:"
            curl -s http://localhost:8888/api/health
            echo ""
            echo ""
            read -p "按Enter继续..."
            ;;
        2)
            echo ""
            echo "=========================================="
            echo "停止服务器"
            echo "=========================================="
            echo ""
            PID=$(netstat -ano | grep :8888 | grep LISTENING | awk '{print $5}' | head -1)
            if [ ! -z "$PID" ]; then
                echo "找到服务器进程: $PID"
                echo "正在停止..."
                taskkill //F //PID $PID
                echo "服务器已停止"
            else
                echo "未找到运行中的服务器"
            fi
            echo ""
            read -p "按Enter继续..."
            ;;
        3)
            echo ""
            echo "=========================================="
            echo "重新启动服务器命令"
            echo "=========================================="
            echo ""
            echo "请复制以下命令并运行:"
            echo ""
            cat << 'EOF'
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
export API_KEY="testnet_api_key_51a69b550a2c4149"
export CORS_ALLOW_ORIGIN="http://localhost:3000"
export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
export RUST_LOG="info"
export SERVER_HOST="127.0.0.1"
export SERVER_PORT="8888"
export TEST_SKIP_DECRYPT="1"
export ALLOW_BRIDGE_MOCKS="1"
cargo run --features test-env --bin hot_wallet
EOF
            echo ""
            read -p "按Enter继续..."
            ;;
        4)
            echo ""
            echo "=========================================="
            echo "最新测试日志（最后20行）"
            echo "=========================================="
            echo ""
            LATEST_LOG=$(ls -t logs/week_test/automated_test_*.log 2>/dev/null | head -1)
            if [ ! -z "$LATEST_LOG" ]; then
                echo "日志文件: $LATEST_LOG"
                echo ""
                tail -20 "$LATEST_LOG"
            else
                echo "未找到测试日志"
            fi
            echo ""
            read -p "按Enter继续..."
            ;;
        5)
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
    echo "DeFi热钱包 - 服务器管理工具"
    echo "=========================================="
    echo ""
done

