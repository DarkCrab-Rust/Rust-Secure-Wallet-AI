# 🔗 前后端API对接文档

## 📋 配置总览

| 配置项 | 前端配置 | 后端配置 | 状态 |
|--------|----------|----------|------|
| **基础URL** | `http://localhost:8888` | `127.0.0.1:8888` | ✅ 对齐 |
| **认证方式** | `Authorization: test_api_key` | API Key验证 | ✅ 对齐 |
| **内容类型** | `Content-Type: application/json` | JSON格式 | ✅ 对齐 |
| **CORS** | `http://localhost:3000` | 允许跨域 | ✅ 对齐 |
| **超时设置** | `10000ms` | `30000ms` (后端) | ✅ 兼容 |
| **默认网络** | `eth` | `eth` | ✅ 对齐 |

---

## 🎯 API端点映射

### 1️⃣ 钱包列表
**前端调用**:
```javascript
walletService.listWallets()
```

**后端接口**:
```http
GET /api/wallets
Authorization: test_api_key
```

**响应格式**:
```json
{
  "wallets": [
    {
      "id": "uuid-string",
      "name": "my_wallet",
      "quantum_safe": false
    }
  ]
}
```

**状态码**:
- `200 OK`: 成功
- `401 Unauthorized`: 认证失败
- `500 Internal Server Error`: 服务器错误

---

### 2️⃣ 创建钱包
**前端调用**:
```javascript
walletService.createWallet({ 
  name: 'my_wallet', 
  quantum_safe: false 
})
```

**后端接口**:
```http
POST /api/wallets
Authorization: test_api_key
Content-Type: application/json

{
  "name": "my_wallet",
  "quantum_safe": false
}
```

**响应格式**:
```json
{
  "id": "uuid-string",
  "name": "my_wallet",
  "quantum_safe": false
}
```

**状态码**:
- `201 Created`: 创建成功
- `400 Bad Request`: 参数错误
- `401 Unauthorized`: 认证失败
- `409 Conflict`: 钱包已存在

---

### 3️⃣ 获取余额
**前端调用**:
```javascript
// 默认使用 eth 网络
walletService.getBalance('my_wallet')

// 指定网络
walletService.getBalance('my_wallet', 'solana')
```

**后端接口**:
```http
GET /api/wallets/my_wallet/balance?network=eth
Authorization: test_api_key
```

**响应格式**:
```json
{
  "balance": "1.234567890",
  "network": "eth",
  "symbol": "ETH"
}
```

**支持的网络**:
- `eth` - 以太坊主网
- `sepolia` - 以太坊测试网
- `polygon` - Polygon网络
- `bsc` - Binance Smart Chain
- `solana` - Solana主网
- `solana-devnet` - Solana测试网

**状态码**:
- `200 OK`: 成功
- `400 Bad Request`: 网络参数无效
- `401 Unauthorized`: 认证失败
- `404 Not Found`: 钱包不存在
- `500 Internal Server Error`: 获取余额失败

---

### 4️⃣ 发送交易
**前端调用**:
```javascript
walletService.sendTransaction('my_wallet', {
  to_address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
  amount: '1.0',
  network: 'eth'  // 可选，默认为 eth
})
```

**后端接口**:
```http
POST /api/wallets/my_wallet/send
Authorization: test_api_key
Content-Type: application/json

{
  "to_address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "amount": "1.0",
  "network": "eth"
}
```

**响应格式**:
```json
{
  "tx_hash": "0xabcdef1234567890...",
  "status": "pending"
}
```

**状态码**:
- `200 OK`: 交易成功发送
- `400 Bad Request`: 参数错误
- `401 Unauthorized`: 认证失败
- `404 Not Found`: 钱包不存在
- `429 Too Many Requests`: 触发速率限制
- `500 Internal Server Error`: 交易失败

---

### 5️⃣ 删除钱包
**前端调用**:
```javascript
walletService.deleteWallet('my_wallet')
```

**后端接口**:
```http
DELETE /api/wallets/my_wallet
Authorization: test_api_key
```

**响应格式**:
```
204 No Content (无响应体)
```

**状态码**:
- `204 No Content`: 删除成功
- `400 Bad Request`: 钱包名称无效
- `401 Unauthorized`: 认证失败
- `404 Not Found`: 钱包不存在
- `500 Internal Server Error`: 删除失败

---

### 6️⃣ 跨链桥接
**前端调用**:
```javascript
walletService.bridgeAssets({
  from_wallet: 'my_wallet',
  from_chain: 'eth',
  to_chain: 'polygon',
  token: 'USDT',
  amount: '100.0'
})
```

**后端接口**:
```http
POST /api/bridge
Authorization: test_api_key
Content-Type: application/json

{
  "from_wallet": "my_wallet",
  "from_chain": "eth",
  "to_chain": "polygon",
  "token": "USDT",
  "amount": "100.0"
}
```

**响应格式**:
```json
{
  "bridge_tx_id": "bridge_uuid_string"
}
```

**状态码**:
- `200 OK`: 桥接请求成功
- `400 Bad Request`: 参数错误
- `401 Unauthorized`: 认证失败
- `404 Not Found`: 钱包不存在
- `429 Too Many Requests`: 触发速率限制
- `500 Internal Server Error`: 桥接失败

---

### 7️⃣ 获取交易历史
**前端调用**:
```javascript
walletService.getTransactionHistory('my_wallet')
```

**后端接口**:
```http
GET /api/wallets/my_wallet/history
Authorization: test_api_key
```

**响应格式**:
```json
{
  "transactions": [
    "tx_hash_1",
    "tx_hash_2",
    "tx_hash_3"
  ]
}
```

**状态码**:
- `200 OK`: 成功
- `401 Unauthorized`: 认证失败
- `404 Not Found`: 钱包不存在
- `500 Internal Server Error`: 获取失败

---

### 8️⃣ 健康检查
**前端调用**:
```javascript
fetch('http://localhost:8888/api/health')
```

**后端接口**:
```http
GET /api/health
```

**响应格式**:
```json
{
  "status": "healthy"
}
```

**状态码**:
- `200 OK`: 服务正常

---

## 🔒 认证机制

### API Key认证
所有API请求（除了 `/api/health`）都需要携带认证头：

```http
Authorization: test_api_key
```

### 动态API Key（开发环境）
前端支持从 `localStorage` 读取自定义API Key：

```javascript
// 设置自定义API Key
localStorage.setItem('api_key', 'my_custom_key');

// 移除自定义API Key（恢复默认）
localStorage.removeItem('api_key');
```

### 认证失败响应
```json
{
  "error": "Unauthorized",
  "code": "AUTH_FAILED"
}
```

---

## ⚠️ 错误处理

### 统一错误格式
后端所有错误响应都使用以下格式：

```json
{
  "error": "错误描述",
  "code": "错误代码"
}
```

### 前端错误拦截
前端已实现统一错误处理，返回格式：

```javascript
{
  status: 400,           // HTTP状态码
  message: "错误描述",    // 错误信息
  data: null             // 响应数据
}
```

### 常见错误代码

| 状态码 | 错误代码 | 说明 | 前端提示 |
|--------|----------|------|----------|
| `400` | `BAD_REQUEST` | 参数错误 | "请求参数有误" |
| `401` | `AUTH_FAILED` | 认证失败 | "认证失败，请检查API密钥" |
| `404` | `NOT_FOUND` | 资源不存在 | "钱包不存在" |
| `429` | `RATE_LIMIT_EXCEEDED` | 速率限制 | "请求触发速率限制(429)" |
| `500` | `INTERNAL_ERROR` | 服务器错误 | "服务器内部错误" |
| `503` | `SERVICE_UNAVAILABLE` | 服务不可用 | "服务暂时不可用" |
| `408` | `REQUEST_TIMEOUT` | 请求超时 | "请求超时，已中止" |

---

## 🚀 速率限制

### 后端限制策略
- **全局限制**: 100请求/分钟/IP
- **桥接端点**: 更严格的限制
- **超时设置**: 
  - 普通端点: 30秒
  - 敏感端点: 20秒

### 前端超时设置
- **Axios超时**: 10秒
- **建议**: 对于长时间操作，前端应显示加载状态

### 触发速率限制时
**后端响应**:
```json
{
  "error": "Rate limit exceeded",
  "code": "RATE_LIMIT_EXCEEDED"
}
```

**前端处理**:
```javascript
// 控制台提示
console.warn('请求触发速率限制(429)，请稍后重试');

// 可选：实现指数退避重试
```

---

## 🔧 开发调试

### 后端启动
```bash
cd Rust-Blockchain-Secure-Wallet
./start_backend.sh
```

服务器将在 `http://localhost:8888` 启动

### 前端配置
```javascript
// src/services/api.js
const API_BASE_URL = 'http://localhost:8888';
const DEFAULT_API_KEY = 'test_api_key';
```

### 验证连接
```bash
# 测试健康检查
curl http://localhost:8888/api/health

# 测试钱包列表（需要认证）
curl -H "Authorization: test_api_key" \
     http://localhost:8888/api/wallets
```

### 常见问题

#### 1. CORS错误
**症状**: `Access-Control-Allow-Origin` 错误

**解决**:
- 确认前端运行在 `http://localhost:3000`
- 检查后端CORS配置已启用
- 验证请求头包含 `Content-Type: application/json`

#### 2. 401认证失败
**症状**: 所有请求返回 `401 Unauthorized`

**解决**:
- 检查 `Authorization` 头是否正确
- 验证API Key是否为 `test_api_key`
- 检查后端是否正确读取环境变量

#### 3. 连接拒绝
**症状**: `ERR_CONNECTION_REFUSED`

**解决**:
- 确认后端服务器已启动
- 验证端口号为 `8888`
- 检查防火墙设置

#### 4. 网络参数错误
**症状**: `Unsupported network` 错误

**解决**:
- 使用支持的网络: `eth`, `sepolia`, `polygon`, `bsc`, `solana`, `solana-devnet`
- 检查网络参数拼写

---

## 📊 测试用例

### 创建并测试钱包
```javascript
// 1. 创建钱包
const wallet = await walletService.createWallet({
  name: 'test_wallet',
  quantum_safe: false
});
console.log('钱包创建:', wallet);

// 2. 获取余额
const balance = await walletService.getBalance('test_wallet', 'eth');
console.log('余额:', balance);

// 3. 发送交易
const tx = await walletService.sendTransaction('test_wallet', {
  to_address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
  amount: '0.1',
  network: 'eth'
});
console.log('交易哈希:', tx.tx_hash);

// 4. 查看历史
const history = await walletService.getTransactionHistory('test_wallet');
console.log('交易历史:', history);

// 5. 删除钱包
await walletService.deleteWallet('test_wallet');
console.log('钱包已删除');
```

### 错误处理测试
```javascript
try {
  // 测试无效网络
  await walletService.getBalance('test_wallet', 'invalid_network');
} catch (err) {
  console.error('预期错误:', err.status, err.message);
  // 应该输出: 400 "Unsupported network"
}

try {
  // 测试不存在的钱包
  await walletService.getBalance('nonexistent_wallet');
} catch (err) {
  console.error('预期错误:', err.status, err.message);
  // 应该输出: 404 "Wallet not found"
}
```

---

## ✅ 对齐检查清单

- [x] **URL对齐**: `http://localhost:8888`
- [x] **认证头**: `Authorization: test_api_key`
- [x] **内容类型**: `Content-Type: application/json`
- [x] **CORS配置**: 允许 `http://localhost:3000`
- [x] **默认网络**: `eth`
- [x] **网络参数**: 查询参数传递
- [x] **超时处理**: 前端10s，后端30s
- [x] **错误格式**: 统一 `{ error, code }` 格式
- [x] **速率限制**: 429状态码处理
- [x] **动态API Key**: localStorage支持

---

## 🎯 下一步

1. **启动后端服务器**
   ```bash
   cd Rust-Blockchain-Secure-Wallet
   ./start_backend.sh
   ```

2. **启动前端应用**
   ```bash
   cd blockchain-wallet-ui
   npm start
   ```

3. **验证连接**
   - 打开浏览器访问 `http://localhost:3000`
   - 打开开发者工具查看网络请求
   - 确认API请求发送到 `http://localhost:8888`

4. **测试功能**
   - 创建钱包
   - 查看余额
   - 发送交易
   - 查看历史

---

## 📞 联系方式

**后端负责人**: 您（Rust后端开发）
**前端负责人**: 前端团队

**问题反馈**: 
- 后端API问题 → 检查 `src/api/server.rs`
- 认证问题 → 检查环境变量 `API_KEY`
- CORS问题 → 检查 `CorsLayer` 配置

---

**文档版本**: v1.0
**最后更新**: 2025-10-24
**状态**: ✅ 前后端完全对齐

