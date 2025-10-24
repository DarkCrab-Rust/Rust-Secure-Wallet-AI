# 🔧 环境变量配置指南

## 📋 必需环境变量

### 1. `WALLET_ENC_KEY`
**用途**: 钱包加密主密钥  
**格式**: Base64编码的32字节密钥  
**示例**: 
```bash
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
```
**生成方法**:
```bash
# Linux/macOS
openssl rand -base64 32

# 或使用 Python
python3 -c "import os, base64; print(base64.b64encode(os.urandom(32)).decode())"
```

### 2. `API_KEY`
**用途**: API认证密钥  
**格式**: 任意安全字符串（建议≥32字节）  
**示例**:
```bash
export API_KEY="your-secure-api-key-min-32-characters-long"
```
**生成方法**:
```bash
# 生成随机API密钥
openssl rand -hex 32
```

---

## 🎨 可选环境变量

### 3. `CORS_ALLOW_ORIGIN` ✨ (新增)
**用途**: CORS跨域源配置  
**默认值**: `http://localhost:3000`  
**格式**: 完整的URL（包括协议和端口）  
**示例**:
```bash
# 开发环境
export CORS_ALLOW_ORIGIN="http://localhost:3000"

# 生产环境
export CORS_ALLOW_ORIGIN="https://your-frontend.com"

# Staging环境
export CORS_ALLOW_ORIGIN="https://staging.your-frontend.com"
```

### 4. `DATABASE_URL`
**用途**: 数据库连接字符串  
**默认值**: `sqlite://./data/wallet.db?mode=rwc`  
**格式**: SQLite URL  
**示例**:
```bash
# 默认路径
export DATABASE_URL="sqlite://./data/wallet.db?mode=rwc"

# 自定义路径
export DATABASE_URL="sqlite:///var/lib/wallet/wallet.db?mode=rwc"

# 内存数据库（仅测试）
export DATABASE_URL="sqlite://:memory:?mode=rwc"
```

### 5. `RUST_LOG`
**用途**: 日志级别配置  
**默认值**: `info`  
**可选值**: `error`, `warn`, `info`, `debug`, `trace`  
**示例**:
```bash
# 生产环境
export RUST_LOG=info

# 开发环境（详细日志）
export RUST_LOG=debug

# 特定模块日志
export RUST_LOG=defi_hot_wallet=debug,tower_http=info
```

### 6. `SERVER_HOST`
**用途**: 服务器监听地址  
**默认值**: `127.0.0.1`  
**示例**:
```bash
# 仅本地访问
export SERVER_HOST=127.0.0.1

# 允许外部访问（谨慎使用）
export SERVER_HOST=0.0.0.0
```

### 7. `SERVER_PORT`
**用途**: 服务器监听端口  
**默认值**: `8888`  
**示例**:
```bash
export SERVER_PORT=8888
```

---

## 🔐 测试环境专用变量

### 8. `TEST_SKIP_DECRYPT`
**用途**: 跳过解密检查（仅测试）  
**默认值**: 未设置  
**示例**:
```bash
export TEST_SKIP_DECRYPT=1
```
⚠️ **警告**: 仅用于测试环境，生产环境禁用！

### 9. `BRIDGE_MOCK`
**用途**: 启用桥接模拟（仅测试）  
**默认值**: 未设置  
**示例**:
```bash
export BRIDGE_MOCK=1
export ALLOW_BRIDGE_MOCKS=1
```
⚠️ **警告**: 仅用于测试环境，生产环境禁用！

---

## 📝 配置文件示例

### `.env` 文件（开发环境）
```bash
# 核心配置
WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
API_KEY=dev-api-key-change-in-production

# CORS配置
CORS_ALLOW_ORIGIN=http://localhost:3000

# 数据库
DATABASE_URL=sqlite://./data/dev_wallet.db?mode=rwc

# 日志
RUST_LOG=debug

# 服务器
SERVER_HOST=127.0.0.1
SERVER_PORT=8888
```

### 生产环境示例
```bash
# 核心配置（使用真实密钥！）
WALLET_ENC_KEY=$(cat /run/secrets/wallet_enc_key)
API_KEY=$(cat /run/secrets/api_key)

# CORS配置
CORS_ALLOW_ORIGIN=https://wallet.yourdomain.com

# 数据库
DATABASE_URL=sqlite:///var/lib/wallet/production.db?mode=rwc

# 日志
RUST_LOG=info

# 服务器
SERVER_HOST=127.0.0.1
SERVER_PORT=8888
```

---

## 🚀 快速启动

### 方法 1: 直接设置环境变量
```bash
export WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
export API_KEY="your-secure-api-key"
export CORS_ALLOW_ORIGIN="http://localhost:3000"

cargo run --bin hot_wallet
```

### 方法 2: 使用 .env 文件
```bash
# 1. 创建 .env 文件
cat > .env << EOF
WALLET_ENC_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
API_KEY=your-secure-api-key
CORS_ALLOW_ORIGIN=http://localhost:3000
DATABASE_URL=sqlite://./data/wallet.db?mode=rwc
RUST_LOG=info
EOF

# 2. 加载环境变量
set -a
source .env
set +a

# 3. 启动服务
cargo run --bin hot_wallet
```

### 方法 3: 使用脚本
```bash
#!/bin/bash
# start_production.sh

# 从安全存储加载密钥
export WALLET_ENC_KEY=$(cat /run/secrets/wallet_enc_key)
export API_KEY=$(cat /run/secrets/api_key)

# 生产配置
export CORS_ALLOW_ORIGIN="https://your-frontend.com"
export DATABASE_URL="sqlite:///var/lib/wallet/wallet.db?mode=rwc"
export RUST_LOG=info
export SERVER_HOST=127.0.0.1
export SERVER_PORT=8888

# 启动服务
exec cargo run --release --bin hot_wallet
```

---

## 🔒 安全最佳实践

### 1. 密钥存储
- ❌ **不要** 将密钥硬编码在代码中
- ❌ **不要** 提交 `.env` 文件到版本控制
- ✅ **使用** 环境变量
- ✅ **使用** 密钥管理服务（AWS Secrets Manager, HashiCorp Vault）
- ✅ **使用** Docker secrets

### 2. 权限管理
```bash
# 确保 .env 文件权限正确
chmod 600 .env

# 确保数据库文件权限正确
chmod 600 /var/lib/wallet/wallet.db
```

### 3. 密钥轮换
```bash
# 定期更换密钥（建议每90天）
# 1. 生成新密钥
NEW_KEY=$(openssl rand -base64 32)

# 2. 更新配置
export WALLET_ENC_KEY="$NEW_KEY"

# 3. 重新加密现有数据（根据实现）
# ./scripts/rotate_encryption_key.sh
```

### 4. 生产环境检查清单
- [ ] 使用强随机密钥（≥256位）
- [ ] 从安全存储加载密钥
- [ ] 设置正确的CORS源
- [ ] 配置生产数据库路径
- [ ] 设置适当的日志级别（info或warn）
- [ ] 限制服务器访问（127.0.0.1）
- [ ] 禁用所有测试环境变量
- [ ] 设置文件权限（600）
- [ ] 配置防火墙规则
- [ ] 启用TLS/HTTPS

---

## 📚 相关文档

- [SECURITY.md](SECURITY.md) - 安全策略
- [README.md](README.md) - 项目说明
- [start_backend.sh](start_backend.sh) - 启动脚本示例

---

**最后更新**: 2025-10-24  
**版本**: 0.1.0

