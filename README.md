# DeFi Hot Wallet - Rust Edition

> NOTE: This repository has been split. This repository now contains only the "wallet core" (core services, crypto, blockchain clients, storage and tests).
> The original full-repository (docs, examples, tools, vendor, and other non-core components) is preserved on the branch `legacy-full-repo` in this same remote. If you need the full history or the archived artifacts, see the `legacy-full-repo` branch.


🔒 **DeFi热钱包，Rust打造，安全如堡垒！** 35天自研MVP，为DeFi玩家量身定制。

[![Rust](https://img.shields.io/badge/rust-1.70+-orange.svg)](https://www.rust-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Security](https://img.shields.io/badge/security-quantum--safe-green.svg)](https://github.com/Yinhang3377/Defi-Hot-wallet-Rust#security-features)

## 🌟 核心特性 / Core Features

### 🛡️ 安全性 / Security
- **量子安全加密** - Quantum-safe encryption (Kyber算法模拟)
- **助记词分片** - Mnemonic phrase sharding (Shamir 2-of-3)
- **多重签名** - Multi-signature support (2-of-3 threshold)
- **HSM内存隔离** - Hardware Security Module simulation
- **零化清栈** - Memory zeroization on drop
- **审计日志** - Comprehensive audit logging

### ⚡ 性能 / Performance
- **Rust零开销** - Zero-cost abstractions
- **异步架构** - Async/await throughout
- **交易<2秒** - Sub-2-second transactions
- **并发安全** - Thread-safe operations

### 🌍 区块链支持 / Blockchain Support
- **以太坊** - Ethereum (ETH) - Full support
- **Solana** - Solana (SOL) - Simulated support
- **可扩展** - Extensible architecture for more chains

### 🌐 国际化 / Internationalization
- **中文** - Chinese (简体中文)
- **英文** - English
- **可扩展** - Extensible i18n framework

## 🚀 快速开始 / Quick Start

### 环境要求 / Prerequisites

```bash
# Rust 1.70+
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 依赖项 / Dependencies
sudo apt-get install build-essential pkg-config libssl-dev
```

See `docs/env_vars.md` for accepted environment variable formats and developer flags (mnemonic export, secret formats).

### 安装 / Installation

```bash
# 克隆仓库 / Clone repository
git clone https://github.com/Yinhang3377/Defi-Hot-wallet-Rust.git
cd Defi-Hot-wallet-Rust

# 构建项目 / Build project
cargo build --release

# 运行测试 / Run tests
cargo test
```

### 使用示例 / Usage Examples

#### 1. 命令行界面 / CLI Interface

```bash
# 创建新钱包 / Create new wallet
./target/release/wallet-cli create --name my-wallet --quantum true

# 查看余额 / Check balance
./target/release/wallet-cli balance --wallet my-wallet --network eth

# 发送交易 / Send transaction
./target/release/wallet-cli send \
  --wallet my-wallet \
  --to 0x742d35Cc6634C0532925a3b844Bc454e4438f44e \
  --amount 0.1 \
  --network eth

# 生成助记词 / Generate mnemonic
./target/release/wallet-cli generate-mnemonic

# 安全状态 / Security status
./target/release/wallet-cli security
```

#### 2. 服务器模式 / Server Mode

```bash
# 启动钱包服务器 / Start wallet server
./target/release/defi-wallet server --port 8080 --host 0.0.0.0

# API 端点 / API Endpoints
curl -X POST http://localhost:8080/api/wallets \
  -H "Content-Type: application/json" \
  -d '{"name": "my-wallet", "quantum_safe": true}'

curl http://localhost:8080/api/wallets/my-wallet/balance?network=eth

curl http://localhost:8080/api/health
curl http://localhost:8080/api/metrics
```

#### 3. 中文界面 / Chinese Interface

```bash
# 使用中文界面 / Use Chinese interface
./target/release/wallet-cli --language zh create --name 我的钱包

# 查看帮助 / Show help
./target/release/wallet-cli --help
```

## 🏗️ 架构设计 / Architecture

### 分层架构 / Layered Architecture

```
┌─────────────────────────────────────────┐
│               API Layer                 │  ← REST API / CLI
├─────────────────────────────────────────┤
│             Core Services               │  ← Wallet Management
├─────────────────────────────────────────┤
│          Security Modules               │  ← Crypto / HSM / Multi-sig
├─────────────────────────────────────────┤
│         Blockchain Clients              │  ← ETH / Solana / Others
├─────────────────────────────────────────┤
│           Storage Layer                 │  ← SQLite / Audit Logs
└─────────────────────────────────────────┘
```

### 核心模块 / Core Modules

- **`src/core/`** - 钱包核心逻辑 / Core wallet logic
- **`src/crypto/`** - 加密模块 / Cryptographic modules
- **`src/blockchain/`** - 区块链集成 / Blockchain integrations
- **`src/storage/`** - 存储层 / Storage layer
- **`src/monitoring/`** - 监控指标 / Monitoring & metrics
- **`src/api/`** - API服务器 / API server
- **`src/i18n/`** - 国际化 / Internationalization

## 🔐 安全特性详解 / Security Features

### 量子安全加密 / Quantum-Safe Encryption

```rust
// 使用模拟的Kyber算法
let mut crypto = QuantumSafeEncryption::new()?;
let keypair = crypto.generate_keypair()?;
let encrypted = crypto.encrypt(sensitive_data)?;
```

### Shamir密钥分片 / Shamir Secret Sharing

```rust
// 2-of-3阈值分片
let shamir = ShamirSecretSharing::new();
let shares = shamir.create_shares(master_key, 2, 3)?; // (密钥, 阈值, 份额数)
let recovered = shamir.reconstruct_secret(&shares[..2])?;
```

### 多重签名 / Multi-Signature

```rust
// 创建多签配置
let config = MultiSignature::create_multisig_config(2, signers)?;

// 提议交易
multisig.propose_transaction(tx_id, to_addr, amount, network, 2)?;

// 签名交易
let complete = multisig.sign_transaction(tx_id, signer, signature)?;
```

### HSM内存隔离 / HSM Memory Isolation

```rust
// 分配安全内存
let region_id = hsm.allocate_secure_memory(64).await?;

// 写入敏感数据
hsm.write_secure_memory(region_id, sensitive_data).await?;

// 自动零化清理
hsm.free_secure_memory(region_id).await?;
```

### 密钥轮换 / Key Rotation

钱包为每个钱包维护可版本化的“签名密钥标签”，默认标签格式：`wallet:<name>:signing`。

- 创建钱包时会自动创建 v1 版本并持久化到 `key_labels`/`key_versions` 表。
- 每次使用当前版本签名时，`usage_count` 会自增。
- 轮换会将旧版本标记为 `retired`，并生成新版本（v+1），更新标签的 `current_version/current_id`。

编程接口（Rust）：

```rust
// 轮换签名密钥
let (old_v, new_v) = wallet_manager.rotate_signing_key("my-wallet").await?;
assert_eq!(old_v + 1, new_v);
```

HTTP 接口（Server）：

```bash
curl -X POST http://localhost:8080/api/wallets/my-wallet/rotate-signing-key \
  -H "Authorization: <YOUR_API_KEY>"

# 响应：
# { "wallet": "my-wallet", "old_version": 1, "new_version": 2 }
```

注意：密钥材料在内存中采用 WALLET_ENC_KEY（Base64 32字节）派生的 AES-256-GCM 包封加密存储。
需要在进程环境中设置：

```bash
export WALLET_ENC_KEY="<base64-encoded-32-bytes>"
```

测试环境（启用 `test-env` feature）会自动注入全零占位键以确保测试稳定；生产环境会拒绝弱默认值。

### 生产安全开关 / Production Safety Switches

- 桥接模拟（bridge mocks）在测试构建中默认启用；在非测试环境下必须显式设置：
  - `ALLOW_BRIDGE_MOCKS=1` 且 同时设置以下任一：
    - `BRIDGE_MOCK_FORCE_SUCCESS=1`（或留空）
    - `BRIDGE_MOCK=1`
    - `FORCE_BRIDGE_SUCCESS=1`
    - `BRIDGE_MOCK_FORCE=1`
- 如果设置了 mock 相关变量但没有 `ALLOW_BRIDGE_MOCKS=1`，服务器会在启动时立即失败并给出清晰提示，避免生产误用。

更多细节见 `SECURITY_NOTES.md`。

## 📊 监控指标 / Monitoring

### Prometheus 指标 / Prometheus Metrics

```bash
# 查看指标 / View metrics
curl http://localhost:8080/api/metrics

# 关键指标 / Key metrics
- wallets_created_total
- transactions_sent_total
- quantum_encryptions_total
- failed_logins_total
- active_connections
- response_time_seconds
```

### 安全监控 / Security Monitoring

- 🚨 **异常检测** - Anomaly detection
- 📝 **审计日志** - Audit logging
- 🛡️ **入侵检测** - Intrusion detection
- ⚠️ **告警系统** - Alert system

## 🧪 测试 / Testing

```bash
# 运行所有测试 / Run all tests
cargo test

# 运行特定模块测试 / Run specific module tests
cargo test crypto::tests
cargo test blockchain::tests

# 性能测试 / Benchmark tests
cargo bench

# 测试覆盖率 / Test coverage
cargo tarpaulin --out Html
```

### 测试覆盖率目标 / Test Coverage Goals

- ✅ **核心逻辑**: 95%+
- ✅ **加密模块**: 90%+
- ✅ **API接口**: 85%+
- ✅ **总体覆盖**: 80%+

## 中国区开发者说明

由于网络限制，CI 可能无法执行完整的依赖下载和测试。请在本地环境执行以下步骤来确保代码质量：

### 配置国内镜像源

在 `~/.cargo/config.toml` 中添加：

```toml
# 本地开发配置 - 多镜像源
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = "tuna"  # 使用清华镜像，可根据网络情况切换

# 清华大学镜像
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# 中科大镜像
[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"

# 字节镜像
[source.bfsu]
registry = "https://mirrors.bfsu.edu.cn/git/crates.io-index/"

[net]
git-fetch-with-cli = true
retry = 3

[http]
# 调整连接参数
timeout = 120
low-speed-limit = 5
low-speed-time = 20
check-revoke = false
```

## 运行测试覆盖率

由于 Windows 原生环境下的测试覆盖率工具兼容性问题，推荐使用以下方式运行测试覆盖率：

### 在 WSL 中运行
1. 打开 WSL 终端
2. 导航到项目目录：`cd /mnt/c/Users/[用户名]/Desktop/Rust区块链/Defi-Hot-wallet-Rust`
3. 运行脚本：`bash scripts/run_coverage.sh`

也可以针对特定文件或模块运行覆盖率：
```bash
# 针对特定文件
bash scripts/run_coverage.sh --file ethereum.rs

# 针对特定模块或测试
bash scripts/run_coverage.sh --module core::wallet_manager_tests
```
在 WSL 中使用的是 Linux 原生工具链，可以更可靠地生成和解析覆盖率数据。

## 🚀 部署 / Deployment

### Docker 部署 / Docker Deployment

```dockerfile
FROM rust:1.70-alpine AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/target/release/defi-wallet /usr/local/bin/
EXPOSE 8080
CMD ["defi-wallet", "server"]
```

### 生产环境配置 / Production Configuration

```toml
# config.toml
[server]
host = "0.0.0.0"
port = 8080
tls_enabled = true

[security]
quantum_safe_default = true
hsm_enabled = true
session_timeout_minutes = 30

[monitoring]
metrics_enabled = true
log_level = "info"
alert_webhook_url = "https://your-webhook-url"
```

## 🔧 配置 / Configuration

### 环境变量 / Environment Variables

```bash
# 数据库配置 / Database configuration
export WALLET_DATABASE_URL="sqlite:./wallet.db"

# 网络配置 / Network configuration
export WALLET_ETHEREUM_RPC_URL="https://mainnet.infura.io/v3/YOUR-PROJECT-ID"
export WALLET_SOLANA_RPC_URL="https://api.mainnet-beta.solana.com"

# 安全配置 / Security configuration
export WALLET_ENCRYPTION_KEY_PATH="./keys/master.key"
export WALLET_HSM_ENABLED="false"
```

## 🔑 派生路径配置 / Derivation Paths Configuration

钱包支持通过配置自定义 HD 派生路径（BIP‑44 for Ethereum 家族；SLIP‑0010 for Solana 家族）。默认值遵循社区惯例，并已在测试中锁定向量保证可重复性。

- ETH 默认路径: m/44'/60'/0'/0/0（account 硬化，change/index 非硬化）
- SOL 默认路径: m/44'/501'/0'/0'/0'（全部硬化，符合 SLIP‑0010/Ed25519 要求）

示例：在 `WalletConfig` 中覆盖 account/change/index（Rust 代码）

```rust
use defi_hot_wallet::core::config::WalletConfig;

let mut cfg = WalletConfig::default();
// 针对 ETH 家族（eth/ethereum/sepolia/polygon/bsc 等）
cfg.derivation.eth.account = 1; // m/44'/60'/1'
cfg.derivation.eth.change = 0;  // change = 0
cfg.derivation.eth.index = 5;   // index = 5 → m/44'/60'/1'/0/5

// 针对 SOL 家族（sol/solana/solana-devnet），全部为硬化层级
cfg.derivation.solana.account = 2; // m/44'/501'/2'/0'/0'
cfg.derivation.solana.change = 0;  // m/44'/501'/2'/0'/0'
cfg.derivation.solana.index = 0;   // m/44'/501'/2'/0'/0'
```

注意：
- 仅更改 account/change/index 三个数字即可，coin_type 已固定（ETH=60, SOL=501）。
- 不同家族的硬化规则已在内部处理，无需显式标注 `'`。
- API/服务读取 `WalletConfig` 后，在 `WalletManager` 中构造派生路径；对生产/测试均生效。

测试向量（简要）：
- ETH 零种子地址从默认路径派生为固定 0x… 值（见 `core::wallet_manager::bip44_eth_tests`）。
- SOL 零种子地址从默认路径派生为 `HVEMhZbB…8BgZ`（见 `core::wallet_manager_slip10_solana_tests`）。


## 🤝 贡献指南 / Contributing

### 开发流程 / Development Workflow

1. **Fork** 项目 / Fork the project
2. **创建分支** / Create feature branch (`git checkout -b feature/amazing-feature`)
3. **提交更改** / Commit changes (`git commit -m 'Add amazing feature'`)
4. **推送分支** / Push branch (`git push origin feature/amazing-feature`)
5. **提交PR** / Create Pull Request

### 代码规范 / Code Standards

```bash
# 格式化代码 / Format code
cargo fmt

# 代码检查 / Lint code
cargo clippy -- -D warnings

# 安全审计 / Security audit
cargo audit

## 迁移说明 / Migration note

注意：为了加强库的秘密处理安全性，`secret_from_vec` 这一 crate 根级别的便利函数已被移除（破坏性变更）。
外部使用者请直接调用 SecretVec 的关联函数：

```rust
// 旧用法（已移除）
// let s = defi_hot_wallet::SecretVec::from_vec(vec![..]);

// 新用法（请使用）
let s = defi_hot_wallet::SecretVec::from_vec(vec![..]);
```

该变更旨在强制使用显式、消耗性的构造器以减少秘密复制的风险。如果你在升级时遇到编译错误，请全局搜寻 `secret_from_vec` 并替换为 `SecretVec::from_vec`。在 CI 中我们也添加了静态检查以避免不安全的便捷 API 被重新引入。
```

## 📜 许可证 / License

本项目基于 [MIT 许可证](LICENSE) - 详见 LICENSE 文件

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details

## 🙏 致谢 / Acknowledgments

- **Rust Foundation** - 卓越的系统编程语言
- **Ethereum Foundation** - 去中心化金融基础设施
- **Solana Labs** - 高性能区块链平台
- **开源社区** - 无私的贡献和支持

## 📞 联系方式 / Contact

- **GitHub**: [@Yinhang3377](https://github.com/Yinhang3377)
- **Issues**: [GitHub Issues](https://github.com/Yinhang3377/Defi-Hot-wallet-Rust/issues)

## ⚠️ 免责声明 / Disclaimer

**重要安全提示 / Important Security Notice:**

此项目仅供教育和研究目的。在生产环境中使用加密货币钱包之前，请进行全面的安全审计。作者不对任何资金损失承担责任。

This project is for educational and research purposes only. Please conduct thorough security audits before using any cryptocurrency wallet in production. The authors are not responsible for any financial losses.

**风险提示 / Risk Warning:**
- 🔐 妥善保管私钥和助记词
- 🛡️ 定期备份钱包数据  
- ⚡ 小额测试后再使用
- 🔍 验证所有交易详情

---

**Made with ❤️ in Rust** | **用Rust制造，充满❤️**
=======
# Secure-Hot-Wallet-in-Rust-

生产级 Rust 热钱包框架，支持多链多资产，安全、高性能、可扩展、易维护。专为以太坊和 Solana 生态系统设计，模块化架构，适用于私钥管理、交易签名和安全存储。Rust 的内存安全性、零成本抽象和并发原语使其成为热钱包的理想选择，有效预防 C/C++ 实现中常见的缓冲区溢出、数据竞争和内存泄漏等漏洞。

## 主要特性
- 多层安全机制
- 插件式架构
- 统一配置与错误处理
- 事件驱动与依赖注入
- 结构化日志与监控
- 完善测试与文档

## 🌟 为什么选择 Rust 开发热钱包？

热钱包处理实时交易签名和私钥加密等敏感操作，因此安全性和性能至关重要。Rust 在这方面表现出色：

### 🔒 无垃圾回收的内存安全
Rust 的所有权模型确保私钥在不再使用时能自动归零并释放，从而消除悬垂指针或 "use-after-free" 等错误。不再需要手动处理内存管理的风险！

### ⚡ 线程安全与并发
内置的 "无畏并发" 特性支持多线程操作（例如并行交易签名）而不会引发数据竞争，这对于高吞吐量的钱包至关重要。

### 🚀 与 C 语言相当的性能
零开销抽象为加密操作（例如通过 secp256k1 进行 ECDSA 签名）提供了原生速度，性能优于 Python 或 JavaScript 等解释型语言。

### 🔐 密码学原语
强大的生态系统提供了像 aes-gcm、zeroize 和 secp256k1 等库，支持抗量子加密和安全密钥生成。

### 🛡️ 可审计性与可组合性
编译时保障和模块化设计使代码更易于审计，减少了区块链环境中的攻击面。

## 快速开始
```sh
# 构建
cargo build
# 运行示例
cargo run --example basic_usage
```

## 目录结构
- src/         主代码
- examples/    用法示例
- tests/       单元/集成测试
- ci/          CI/CD配置
- docs/        开发文档

## 🛠️ 近期变更

### 2025-09-19
- 移除未使用的 `encryption_key` 字段，改为使用 `salt` 动态生成密钥。
- 删除未集成的 `derive_encryption_key` 函数。
- 移除 `MemoryProtector` 结构体及其方法。
- 测试覆盖率优化，确保核心功能稳定。
>>>>>>> be35db3d094cb6edd3c63585f33fdcb299a57158
