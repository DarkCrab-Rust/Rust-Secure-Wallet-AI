# 🧪 测试网部署完整指南

## 🎯 目标
**在测试网上运行1周，无需前端，验证后端功能**

---

## ⚡ 快速开始（2步）

### **Step 1: 启动服务器** 

打开Git Bash终端：

```bash
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
chmod +x start_testnet.sh
./start_testnet.sh
```

**会自动**:
- ✅ 生成安全的随机密钥
- ✅ 保存配置到 `.env.testnet.local`
- ✅ 创建数据库目录
- ✅ 启动API服务器

**看到这个说明成功**:
```
Server listening on 127.0.0.1:8888
```

---

### **Step 2: 测试API**

**打开新的Git Bash终端**：

```bash
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
chmod +x test_api_after_start.sh
./test_api_after_start.sh
```

**会自动测试**:
- ✅ 健康检查
- ✅ 创建钱包
- ✅ 查询余额
- ✅ 备份钱包
- ✅ 交易历史
- ✅ 系统指标

---

## 📋 详细步骤

### **1. 启动服务器**

```bash
# 终端1 - 服务器
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
./start_testnet.sh
```

**重要**: 
- 服务器会持续运行在这个终端
- **不要关闭这个终端**
- 密钥已保存到 `.env.testnet.local`

---

### **2. 运行基础测试**

```bash
# 终端2 - 测试
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
./test_api_after_start.sh
```

**预期结果**:
```json
// 健康检查
{"status": "ok"}

// 创建钱包
{
  "id": "test_wallet_1",
  "name": "test_wallet_1",
  "quantum_safe": false
}

// 查询余额
{
  "wallet": "test_wallet_1",
  "balance": "0",
  "network": "sepolia"
}
```

---

### **3. 获取测试币**

#### **步骤**:

1. **获取钱包地址**
   ```bash
   curl -s -X GET "http://localhost:8888/api/wallets" \
     -H "Authorization: $(grep API_KEY .env.testnet.local | cut -d= -f2)" \
     | jq -r '.[0]'
   ```

2. **从水龙头获取测试币**
   
   **Ethereum Sepolia**:
   - 访问: https://sepoliafaucet.com/
   - 或: https://www.alchemy.com/faucets/ethereum-sepolia
   - 输入钱包地址
   - 获取 0.5 SepoliaETH
   
   **Polygon Mumbai/Amoy**:
   - 访问: https://faucet.polygon.technology/
   - 输入钱包地址
   - 获取测试MATIC

3. **等待10分钟（确认到账）**

4. **查询余额**
   ```bash
   curl -s -X GET "http://localhost:8888/api/wallets/test_wallet_1/balance?network=sepolia" \
     -H "Authorization: $(grep API_KEY .env.testnet.local | cut -d= -f2)" \
     | jq '.'
   ```

---

### **4. 发送测试交易**

```bash
# 加载API密钥
source .env.testnet.local

# 发送交易
curl -X POST "http://localhost:8888/api/wallets/test_wallet_1/send" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "amount": "0.001",
    "network": "sepolia"
  }' | jq '.'
```

**预期结果**:
```json
{
  "tx_hash": "0x1234...5678",
  "status": "sent"
}
```

**验证交易**:
- 访问 Sepolia区块浏览器: https://sepolia.etherscan.io/
- 粘贴交易哈希
- 查看交易状态

---

## 📊 1周测试计划

### **Day 1-2: 基础功能**
- ✅ 创建/删除钱包
- ✅ 备份/恢复
- ✅ 余额查询
- ✅ 获取测试币

### **Day 3-4: 交易测试**
- ✅ 发送交易
- ✅ 交易历史
- ✅ 多链测试
- ✅ 交易追踪

### **Day 5: 压力测试**
- ✅ 并发请求
- ✅ 大量钱包
- ✅ 性能监控

### **Day 6: 安全测试**
- ✅ 认证测试
- ✅ 输入验证
- ✅ 速率限制

### **Day 7: 稳定性验证**
- ✅ 24小时运行
- ✅ 监控异常
- ✅ 总结问题

---

## 🛠️ 测试工具

### **工具1: Bash脚本** (已提供)
```bash
./test_api_after_start.sh
```

### **工具2: Python脚本** (已提供)
```bash
python3 test_api.py
```

### **工具3: Postman**
1. 打开Postman
2. Import → 选择 `Postman测试集合.json`
3. 修改变量中的 `api_key` 为您的实际API密钥
4. 运行整个集合

### **工具4: curl命令**
```bash
# 手动测试任何API
curl -X GET "http://localhost:8888/api/wallets" \
  -H "Authorization: YOUR_API_KEY"
```

---

## 📝 监控检查清单

### **每日检查**
- [ ] 服务器是否运行
- [ ] 查看日志文件
- [ ] 测试基本API
- [ ] 记录异常情况

### **查看日志**
```bash
# 如果使用systemd
journalctl -u wallet-service -f

# 如果在终端运行
# 日志会直接显示在终端1
```

### **检查进程**
```bash
ps aux | grep hot_wallet
```

### **检查端口**
```bash
netstat -an | grep 8888
# 或
lsof -i :8888
```

---

## 🐛 常见问题

### **问题1: 服务器无法启动**
```
错误: Refusing to start: Insecure WALLET_ENC_KEY
解决: 使用 start_testnet.sh 脚本（会自动生成安全密钥）
```

### **问题2: curl返回空**
```
原因: 服务器未启动或端口错误
解决: 检查终端1是否显示 "Server listening"
```

### **问题3: 401 Unauthorized**
```
原因: API密钥错误
解决: 使用 .env.testnet.local 中的正确API密钥
```

### **问题4: 余额始终为0**
```
原因: 未从水龙头获取测试币
解决: 访问 https://sepoliafaucet.com/ 获取测试币
```

---

## 🎯 成功标准

### **1周后应该达到**:
- ✅ API稳定运行7天
- ✅ 成功发送至少10笔测试交易
- ✅ 无严重崩溃或错误
- ✅ 性能指标正常
- ✅ 安全测试全部通过

---

## 📞 支持

遇到问题？查看：
- `测试网1周测试计划.md` - 详细测试计划
- `ENV_VARIABLES.md` - 环境变量说明
- `SECURITY.md` - 安全策略

---

## 🚀 立即开始！

### **一键启动命令**:
```bash
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet

# 终端1: 启动服务
chmod +x start_testnet.sh
./start_testnet.sh

# 终端2: 运行测试（启动成功后）
chmod +x test_api_after_start.sh
./test_api_after_start.sh
```

**祝测试顺利！** 🎉

