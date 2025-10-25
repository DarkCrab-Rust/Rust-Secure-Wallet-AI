# DeFi 热钱包 - 启动和测试指令

## 📋 重要信息

### API密钥：
```
testnet_api_key_51a69b550a2c4149
```

### 服务器地址：
```
http://localhost:8888
```

### ⚠️ 关键提示：
- ✅ 使用原始API密钥格式：`Authorization: testnet_api_key_51a69b550a2c4149`
- ❌ 不要使用Bearer格式：`Authorization: Bearer testnet_api_key_51a69b550a2c4149`
- ✅ 服务器启动后等待15秒再测试
- ✅ 所有环境变量必须在启动服务器前设置

---

## 🚀 服务器启动指令

### Git Bash / WSL:
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

# 设置环境变量
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
export API_KEY="testnet_api_key_51a69b550a2c4149"
export CORS_ALLOW_ORIGIN="http://localhost:3000"
export DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
export RUST_LOG="info"
export SERVER_HOST="127.0.0.1"
export SERVER_PORT="8888"
export TEST_SKIP_DECRYPT="1"
export ALLOW_BRIDGE_MOCKS="1"

# 启动服务器
cargo run --features test-env --bin hot_wallet
```

---

## 🧪 后端验证测试

### PowerShell 快速确认：

#### 1. 健康检查
```powershell
Invoke-RestMethod http://localhost:8888/api/health
```

#### 2. 钱包列表（注意是原始密钥，无 Bearer 前缀）
```powershell
Invoke-RestMethod http://localhost:8888/api/wallets -Headers @{ Authorization = 'testnet_api_key_51a69b550a2c4149' }
```

#### 3. 创建钱包
```powershell
$body = @{
    name = "test_wallet"
    description = "测试钱包"
    quantum_safe = $false
} | ConvertTo-Json

Invoke-RestMethod http://localhost:8888/api/wallets `
    -Method POST `
    -Headers @{ Authorization = 'testnet_api_key_51a69b550a2c4149'; 'Content-Type' = 'application/json' } `
    -Body $body
```

#### 4. 余额查询
```powershell
Invoke-RestMethod "http://localhost:8888/api/wallets/test_wallet/balance?network=eth" `
    -Headers @{ Authorization = 'testnet_api_key_51a69b550a2c4149' }
```

#### 5. 交易历史
```powershell
Invoke-RestMethod http://localhost:8888/api/wallets/test_wallet/history `
    -Headers @{ Authorization = 'testnet_api_key_51a69b550a2c4149' }
```

#### 6. 网络状态
```powershell
Invoke-RestMethod http://localhost:8888/api/metrics `
    -Headers @{ Authorization = 'testnet_api_key_51a69b550a2c4149' }
```

---

### CMD 快速确认：

#### 1. 健康检查
```cmd
curl.exe -s http://localhost:8888/api/health
```

#### 2. 钱包列表
```cmd
curl.exe -s -H "Authorization: testnet_api_key_51a69b550a2c4149" http://localhost:8888/api/wallets
```

#### 3. 创建钱包
```cmd
curl.exe -s -X POST http://localhost:8888/api/wallets -H "Authorization: testnet_api_key_51a69b550a2c4149" -H "Content-Type: application/json" -d "{\"name\": \"test_wallet\", \"description\": \"测试钱包\", \"quantum_safe\": false}"
```

#### 4. 余额查询
```cmd
curl.exe -s -H "Authorization: testnet_api_key_51a69b550a2c4149" http://localhost:8888/api/wallets/test_wallet/balance?network=eth
```

#### 5. 交易历史
```cmd
curl.exe -s -H "Authorization: testnet_api_key_51a69b550a2c4149" http://localhost:8888/api/wallets/test_wallet/history
```

#### 6. 网络状态
```cmd
curl.exe -s -H "Authorization: testnet_api_key_51a69b550a2c4149" http://localhost:8888/api/metrics
```

---

### Git Bash 完整测试：

```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

# 设置API密钥
export API_KEY="testnet_api_key_51a69b550a2c4149"

echo "=== 完整API测试 ==="

echo "1. 健康检查:"
curl -s http://localhost:8888/api/health
echo -e "\n"

echo "2. 钱包列表:"
curl -s -X GET http://localhost:8888/api/wallets -H "Authorization: $API_KEY"
echo -e "\n"

echo "3. 创建钱包:"
curl -s -X POST http://localhost:8888/api/wallets \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "test_wallet", "description": "测试钱包", "quantum_safe": false}'
echo -e "\n"

echo "4. 余额查询:"
curl -s -X GET http://localhost:8888/api/wallets/test_wallet/balance?network=eth \
  -H "Authorization: $API_KEY"
echo -e "\n"

echo "5. 交易历史:"
curl -s -X GET http://localhost:8888/api/wallets/test_wallet/history \
  -H "Authorization: $API_KEY"
echo -e "\n"

echo "6. 网络状态:"
curl -s -X GET http://localhost:8888/api/metrics \
  -H "Authorization: $API_KEY"
echo -e "\n"
```

---

## 🔄 1周自动化测试

### 启动自动化测试：
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

# 运行1周自动化测试
./week_automated_test_final.sh
```

### 测试配置：
- 测试时长：7天
- 测试间隔：30分钟
- 总测试轮数：336轮
- 日志位置：`logs/week_test/`

### 停止测试：
按 `Ctrl+C` 停止自动化测试

---

## 🛠️ 故障排查

### 1. 检查服务器是否运行
```bash
netstat -ano | grep :8888
```

### 2. 停止占用8888端口的进程
```bash
# 查找进程ID
netstat -ano | grep :8888

# 停止进程（替换 <PID> 为实际进程ID）
taskkill //F //PID <PID>
```

### 3. 查看测试日志
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"
cat logs/week_test/automated_test_*.log
```

---

## 📊 预期响应示例

### 健康检查：
```json
{"status":"ok","timestamp":"2025-10-25T03:40:32.579791300+00:00","version":"0.1.0"}
```

### 钱包列表：
```json
[{"id":"wallet_1","name":"wallet_1","quantum_safe":false}]
```

### 创建钱包：
```json
{"id":"test_wallet","name":"test_wallet","quantum_safe":false}
```

### 余额查询：
```json
{"balance":"0.000000000000000000","network":"eth","symbol":"ETH"}
```

### 交易历史：
```json
{"transactions":[]}
```

### 网络状态：
```
# HELP defi_hot_wallet_requests_total Total number of requests
# TYPE defi_hot_wallet_requests_total counter
defi_hot_wallet_requests_total 0
```

---

## 📝 注意事项

1. **API密钥格式**：
   - ✅ 正确：`Authorization: testnet_api_key_51a69b550a2c4149`
   - ❌ 错误：`Authorization: Bearer testnet_api_key_51a69b550a2c4149`

2. **环境变量**：
   - 必须在启动服务器前设置所有环境变量
   - 重启服务器时需要重新设置环境变量

3. **端口占用**：
   - 确保8888端口未被其他程序占用
   - 同一时间只能运行一个服务器实例

4. **测试顺序**：
   - 先启动服务器
   - 等待15秒确保服务器完全启动
   - 再运行测试命令

---

## 🎯 快速启动流程

1. **打开Git Bash**
2. **启动服务器**（复制上面的服务器启动指令）
3. **等待15秒**
4. **打开新的Git Bash窗口**
5. **运行测试**（复制上面的测试指令）
6. **查看结果**

---

**祝测试顺利！** 🚀

