# 🔧 Day 2: 修复余额查询 - 完整操作指南

## 🎯 今天的目标
- ✅ 诊断并修复余额查询问题
- ✅ 验证所有网络的余额功能
- ✅ 准备获取测试币

---

## 🔍 问题诊断结果

### **发现的问题**:
❌ `config.blockchain.networks` 是空的！

**代码位置**: `src/main.rs` 第97行
```rust
// 修复前:
blockchain: BlockchainConfig {
    networks: HashMap::new(), // 空的！没有任何网络配置
    default_network: Some("eth".to_string()),
}
```

**影响**:
- 无法初始化任何区块链客户端
- 所有余额查询失败
- 无法发送交易

---

## ✅ 修复方案

### **已修复**:
1. 添加 `load_blockchain_config()` 函数 - 从 `config.toml` 加载
2. 添加 `create_default_blockchain_config()` 函数 - 提供默认配置
3. 支持7个网络：
   - eth (Ethereum Mainnet)
   - sepolia (Ethereum Sepolia Testnet) ⭐
   - polygon (Polygon Mainnet)
   - bsc (BSC Mainnet)
   - bsctestnet (BSC Testnet)
   - solana (Solana Mainnet)
   - solana-devnet (Solana Devnet) ⭐

**修复文件**: `src/main.rs`

---

## 🚀 操作步骤

### **Step 1: 编译修复后的代码**

在Git Bash中运行：

```bash
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
chmod +x day2_test_fix.sh
./day2_test_fix.sh
```

**预期输出**:
```
✅ 编译成功！
```

---

### **Step 2: 重启服务器**

#### **在终端1（服务器终端）**:

1. 按 `Ctrl+C` 停止旧服务器

2. 重新启动：
   ```bash
   cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
   ./start_testnet.sh
   ```

**新的日志应该显示**:
```
✅ Loaded network config: eth (RPC: https://eth.llamarpc.com)
✅ Loaded network config: sepolia (RPC: https://sepolia.drpc.org)
✅ Loaded network config: polygon (RPC: ...)
...
✅ Initializing client for network: sepolia
✅ Connected to sepolia (Chain ID: 11155111)
```

---

### **Step 3: 验证修复**

#### **在终端2（测试终端）**:

```bash
cd ~/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
chmod +x day2_verify_balance.sh
./day2_verify_balance.sh
```

**预期结果**:
```json
// eth网络
{
  "balance": "0",
  "network": "eth",
  "symbol": "ETH",
  "wallet": "day2_test_wallet"
}
✅ 成功！

// sepolia网络
{
  "balance": "0",
  "network": "sepolia",
  "symbol": "ETH",
  "wallet": "day2_test_wallet"
}
✅ 成功！

// ... 其他网络
```

---

## 📋 Day 2 完整测试清单

### **上午任务** ✅
- [x] 诊断问题（发现配置为空）
- [x] 修复代码（添加配置加载）
- [x] 编译代码
- [x] 重启服务器
- [x] 验证修复

### **下午任务**
- [ ] 查看所有钱包
- [ ] 获取钱包地址
- [ ] 从水龙头获取测试币
- [ ] 准备明天的交易测试

---

## 🎯 获取测试币指南

### **1. 获取钱包地址**

```bash
source .env.testnet.local

# 创建一个专门用于接收测试币的钱包
curl -X POST "http://localhost:8888/api/wallets" \
  -H "Authorization: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "faucet_wallet", "quantum_safe": false}'

# 备份钱包获取地址（助记词会包含地址信息）
# 或者从数据库/日志中获取
```

⚠️ **注意**: 当前API可能不直接返回地址，需要：
1. 从备份中获取
2. 或添加API端点返回地址
3. 或从数据库查询

### **2. Sepolia水龙头**

**推荐水龙头** (免费):
- https://sepoliafaucet.com/ (需要Alchemy账号)
- https://www.alchemy.com/faucets/ethereum-sepolia
- https://sepolia-faucet.pk910.de/ (PoW水龙头)

**步骤**:
1. 访问水龙头网站
2. 输入钱包地址
3. 完成验证（可能需要登录）
4. 等待10-15分钟

**预期**:
- 获得 0.5 SepoliaETH

### **3. 验证到账**

```bash
source .env.testnet.local

# 每5分钟查询一次
while true; do
  echo "$(date): 查询余额..."
  curl -s -X GET "http://localhost:8888/api/wallets/faucet_wallet/balance?network=sepolia" \
    -H "Authorization: $API_KEY"
  echo ""
  sleep 300  # 5分钟
done
```

---

## 🎊 Day 2 预期成果

### **修复后应该看到**:
- ✅ 所有网络余额查询成功
- ✅ 返回 `{"balance": "0", ...}` 而不是错误
- ✅ 服务器日志显示网络初始化成功
- ✅ 可以查询Sepolia测试网余额

### **为Day 3准备**:
- ✅ 余额功能正常
- ✅ 有测试币
- ✅ 可以发送交易
- ✅ 验证真实区块链交互

---

## 📊 Day 2 成功指标

- [ ] 余额查询成功率 = 100%
- [ ] 所有7个网络都能查询
- [ ] 获得Sepolia测试币
- [ ] 无服务器崩溃
- [ ] 响应时间 < 2秒

---

## 🚀 快速命令参考

```bash
# 编译修复
./day2_test_fix.sh

# 重启服务器（终端1）
./start_testnet.sh

# 验证修复（终端2）
./day2_verify_balance.sh

# 持续监控
watch -n 10 'curl -s http://localhost:8888/api/health'
```

---

**Day 2 加油！修复余额查询！** 💪

