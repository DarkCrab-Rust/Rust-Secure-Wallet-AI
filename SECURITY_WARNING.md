# ⚠️ 安全警告

## 🔒 测试环境说明

**本仓库中的所有密钥和配置仅用于测试和演示目的!**

### 测试密钥列表

以下密钥**没有任何实际价值**,不能用于生产环境:

```bash
# 测试API密钥
testnet_api_key_51a69b550a2c4149

# 测试加密密钥
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
```

**这些密钥**:
- ✅ 仅用于本地开发和测试
- ✅ 不连接任何真实资产
- ✅ 使用测试网络 (Sepolia, Solana Devnet)
- ✅ 没有真实用户数据

---

## 🚫 生产环境部署警告

**请勿直接将本项目部署到生产环境!**

如果要用于生产环境,必须:

### 1. 更换所有密钥

```bash
# ❌ 不要使用
API_KEY=testnet_api_key_51a69b550a2c4149

# ✅ 生成新的随机密钥
API_KEY=$(openssl rand -hex 32)
```

### 2. 使用强加密密钥

```bash
# ❌ 不要使用测试密钥
WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

# ✅ 生成强加密密钥
WALLET_ENC_KEY=$(openssl rand -base64 32)
```

### 3. 配置生产环境

```bash
# 使用HTTPS
SERVER_HOST=0.0.0.0
SERVER_PORT=443

# 使用主网RPC
ETH_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# 禁用测试功能
ALLOW_BRIDGE_MOCKS=0
TEST_SKIP_DECRYPT=0
```

### 4. 安全措施

- ✅ 启用防火墙
- ✅ 配置访问控制
- ✅ 使用HTTPS/TLS
- ✅ 定期轮换密钥
- ✅ 启用审计日志
- ✅ 实施速率限制
- ✅ 使用硬件安全模块(HSM)

---

## 🔐 密钥管理最佳实践

### 永远不要

- ❌ 在代码中硬编码生产密钥
- ❌ 提交 `.env` 文件到Git
- ❌ 在公开渠道分享密钥
- ❌ 使用弱密码或默认密钥
- ❌ 在多个环境共用密钥

### 应该做的

- ✅ 使用环境变量
- ✅ 使用密钥管理服务 (AWS KMS, Azure Key Vault)
- ✅ 定期轮换密钥
- ✅ 使用强随机密钥
- ✅ 为每个环境使用不同的密钥

---

## 📊 风险评估

### 本项目的测试密钥

| 密钥类型 | 风险等级 | 原因 |
|---------|---------|------|
| API密钥 | 🟢 低 | 仅用于测试,无真实资产 |
| 加密密钥 | 🟢 低 | 代码拒绝全零密钥 |
| 数据库 | 🟢 低 | 已被.gitignore忽略 |

### 如果误用于生产

| 场景 | 风险等级 | 后果 |
|-----|---------|------|
| 使用测试API密钥 | 🟡 中 | 未授权访问 |
| 使用测试加密密钥 | 🔴 高 | 资产被盗 |
| 暴露私钥 | 🔴 极高 | 资产全部丢失 |

---

## 🛡️ 代码中的安全措施

### 1. 密钥验证

```rust
// src/core/wallet/create.rs
if key.iter().all(|&b| b == 0) {
    return Err("Refusing to start: Insecure WALLET_ENC_KEY detected");
}
```

### 2. 内存保护

```rust
use zeroize::Zeroize;

// 敏感数据自动清零
let mut secret = vec![0u8; 32];
// ... 使用 secret ...
secret.zeroize();  // 自动清理
```

### 3. 常量时间比较

```rust
use subtle::ConstantTimeEq;

// 防止时序攻击
if api_key.ct_eq(&expected_key).into() {
    // 验证通过
}
```

---

## 📝 报告安全问题

如果你发现安全漏洞,请**不要**公开披露。

请通过以下方式私下报告:
- 📧 Email: [你的邮箱]
- 🔒 GitHub Security Advisory

我们会在24小时内响应。

---

## 🎓 学习资源

### 区块链安全

- [智能合约安全最佳实践](https://consensys.github.io/smart-contract-best-practices/)
- [以太坊安全指南](https://ethereum.org/en/developers/docs/security/)
- [Solana安全最佳实践](https://docs.solana.com/developing/programming-model/security)

### Rust安全

- [Rust安全编码指南](https://anssi-fr.github.io/rust-guide/)
- [OWASP Rust安全](https://owasp.org/www-community/vulnerabilities/Rust)

### 密码学

- [密钥管理最佳实践](https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html)
- [加密最佳实践](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

---

## ✅ 安全检查清单

在部署前,请确认:

### 密钥安全
- [ ] 已更换所有测试密钥
- [ ] 使用强随机密钥
- [ ] 密钥存储在安全位置
- [ ] 配置了密钥轮换

### 网络安全
- [ ] 启用HTTPS/TLS
- [ ] 配置防火墙
- [ ] 实施访问控制
- [ ] 启用速率限制

### 应用安全
- [ ] 禁用测试功能
- [ ] 启用审计日志
- [ ] 配置监控告警
- [ ] 实施备份策略

### 代码安全
- [ ] 通过安全审计
- [ ] 没有已知漏洞
- [ ] 依赖项已更新
- [ ] 通过所有测试

---

## 🎯 免责声明

本项目为教育和演示目的而创建。

**使用本项目的风险由用户自行承担。**

作者不对以下情况负责:
- 因误用导致的资产损失
- 因配置错误导致的安全问题
- 因未遵循最佳实践导致的后果

**在处理真实资产前,请咨询专业的安全顾问。**

---

**安全第一!** 🔒

