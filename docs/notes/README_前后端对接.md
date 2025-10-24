# 🚀 前后端对接 - 快速开始指南

> **状态**: ✅ 已完成配置对齐，可以立即开始联调！  
> **最后更新**: 2025-10-24

---

## 📍 项目概览

**后端**: Rust区块链钱包服务器  
**前端**: React钱包用户界面  
**通信协议**: RESTful API over HTTP  
**认证方式**: API Key

---

## ⚡ 5分钟快速启动

### 1️⃣ 启动后端（终端1）
```bash
cd Rust-Blockchain-Secure-Wallet
./start_backend.sh
```

等待看到：
```
Server listening on 127.0.0.1:8888
```

### 2️⃣ 验证后端（终端2）
```bash
cd Rust-Blockchain-Secure-Wallet
./verify_api_alignment.sh
```

看到所有 ✅ 表示正常。

### 3️⃣ 启动前端（终端3）
```bash
cd blockchain-wallet-ui
npm start
```

浏览器自动打开 `http://localhost:3000`

### 4️⃣ 测试连接
打开浏览器开发者工具控制台，粘贴：
```javascript
fetch('http://localhost:8888/api/health')
  .then(r => r.json())
  .then(console.log);
```

看到 `{status: "healthy"}` 表示连接成功！

---

## 📚 文档导航

### 🎯 我想要...

#### 📖 **查看完整的API文档**
👉 [前后端API对接文档.md](./前后端API对接文档.md)
- 所有API端点详细说明
- 请求/响应格式
- 错误码说明
- 代码示例

#### 🧪 **运行测试验证对接**
👉 [前端集成测试指南.md](./前端集成测试指南.md)
- 完整的测试用例
- 浏览器控制台测试代码
- Jest集成测试示例
- 问题排查方法

#### 📋 **快速查阅配置信息**
👉 [快速参考_前后端对接.txt](./快速参考_前后端对接.txt)
- 一页纸速查表
- 常用命令
- API端点列表
- 问题排查清单

#### 📊 **了解对接完成情况**
👉 [前后端对接完成总结.md](./前后端对接完成总结.md)
- 修改清单
- 对齐验证
- 测试结果
- 后续工作

---

## 🔧 配置速查

### 服务器地址
```
后端: http://localhost:8888
前端: http://localhost:3000
```

### 认证配置
```javascript
// 前端默认配置
const headers = {
  'Authorization': 'test_api_key',
  'Content-Type': 'application/json'
};
```

### 支持的网络
```
eth, sepolia, polygon, bsc, solana, solana-devnet
```

---

## 🎯 常用API示例

### 创建钱包
```javascript
const wallet = await walletService.createWallet({
  name: 'my_wallet',
  quantum_safe: false
});
```

### 查询余额
```javascript
// 默认使用 eth 网络
const balance = await walletService.getBalance('my_wallet');

// 指定网络
const solBalance = await walletService.getBalance('my_wallet', 'solana');
```

### 发送交易
```javascript
const tx = await walletService.sendTransaction('my_wallet', {
  to_address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
  amount: '1.0',
  network: 'eth'  // 可选，默认eth
});
```

---

## ⚠️ 常见问题

### ❌ ERR_CONNECTION_REFUSED
**原因**: 后端服务器未启动  
**解决**: 运行 `./start_backend.sh`

### ❌ CORS Error
**原因**: 前端不在 `localhost:3000`  
**解决**: 确认前端运行在正确端口

### ❌ 401 Unauthorized
**原因**: API Key 错误  
**解决**: 检查 `Authorization: test_api_key`

### ❌ 500 获取余额失败
**原因**: 后端未配置区块链客户端  
**解决**: 这是正常的，实际部署时需要配置RPC节点

---

## 📞 获取帮助

### 查看日志
```bash
# 后端日志
# 直接在运行 ./start_backend.sh 的终端查看

# 前端日志
# 浏览器开发者工具 -> Console
```

### 运行诊断
```bash
# 验证后端配置
./verify_api_alignment.sh

# 测试健康检查
curl http://localhost:8888/api/health

# 测试认证
curl -H "Authorization: test_api_key" \
     http://localhost:8888/api/wallets
```

---

## 🎓 学习路径

1. **第一步**: 阅读本文档，理解基本概念
2. **第二步**: 启动后端和前端，验证连接
3. **第三步**: 阅读 [API对接文档](./前后端API对接文档.md)，了解所有端点
4. **第四步**: 运行 [集成测试](./前端集成测试指南.md)，验证功能
5. **第五步**: 开始开发你的功能！

---

## ✅ 检查清单

开始开发前，确认以下各项：

- [ ] 后端服务器已启动（8888端口）
- [ ] 前端应用已启动（3000端口）
- [ ] 健康检查接口正常（`/api/health`）
- [ ] 认证机制工作正常（401/200响应正确）
- [ ] CORS配置正确（无跨域错误）
- [ ] 已阅读API文档
- [ ] 已运行验证脚本

---

## 🚀 开始开发

现在你已经准备好了！

```javascript
// 在你的React组件中
import { walletService } from './services/api';

function MyComponent() {
  const [wallets, setWallets] = useState([]);
  
  useEffect(() => {
    walletService.listWallets()
      .then(data => setWallets(data.wallets))
      .catch(error => console.error(error));
  }, []);
  
  return (
    <div>
      {wallets.map(wallet => (
        <div key={wallet.id}>{wallet.name}</div>
      ))}
    </div>
  );
}
```

---

## 📋 快速命令参考

```bash
# 后端操作
./start_backend.sh              # 启动后端
./verify_api_alignment.sh       # 验证配置

# 健康检查
curl http://localhost:8888/api/health

# 获取钱包列表
curl -H "Authorization: test_api_key" \
     http://localhost:8888/api/wallets

# 创建钱包
curl -X POST \
     -H "Authorization: test_api_key" \
     -H "Content-Type: application/json" \
     -d '{"name":"test","quantum_safe":false}' \
     http://localhost:8888/api/wallets
```

---

**祝开发顺利！** 🎉

如有问题，请查看详细文档或联系后端团队。

