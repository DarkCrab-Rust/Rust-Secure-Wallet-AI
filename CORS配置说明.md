# 🌐 CORS跨域配置说明

## 🔍 问题说明

当前端(浏览器)访问后端API时,可能会遇到CORS跨域错误:

```
Access to fetch at 'http://localhost:8888/api/wallets' from origin 'http://localhost:3000' 
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

---

## ✅ 已配置的CORS设置

后端已经配置了完整的CORS支持:

### 📋 当前配置

```rust
// src/api/server.rs
CorsLayer::new()
    .allow_origin("http://localhost:3000")  // 允许的前端地址
    .allow_methods([GET, POST, DELETE, OPTIONS, PUT, PATCH])
    .allow_headers([AUTHORIZATION, CONTENT_TYPE, ACCEPT, ORIGIN])
    .expose_headers([CONTENT_TYPE, AUTHORIZATION])
    .allow_credentials(true)
    .max_age(3600秒)
```

### 🔧 环境变量控制

CORS允许的源地址通过环境变量 `CORS_ALLOW_ORIGIN` 控制:

```bash
# 默认值 (支持多个源)
CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"

# 可以修改为其他地址
CORS_ALLOW_ORIGIN="http://localhost:5173"  # Vite
CORS_ALLOW_ORIGIN="http://localhost:8080"  # Vue CLI
```

---

## 🚀 解决方案

### 方案1: 确保环境变量正确 (推荐)

#### 启动服务器时设置:

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000"
cargo run --features test-env --bin hot_wallet
```

#### 或使用脚本启动:

```bash
bash wallet_tools.sh
# 选择 "1. 启动服务器"
# 脚本会自动设置 CORS_ALLOW_ORIGIN
```

---

### 方案2: 修改前端地址

如果前端运行在不同端口,修改环境变量:

```bash
# 前端在 5173 端口 (Vite默认)
export CORS_ALLOW_ORIGIN="http://localhost:5173"

# 前端在 8080 端口
export CORS_ALLOW_ORIGIN="http://localhost:8080"
```

---

### 方案3: 允许所有源 (仅开发环境)

**⚠️ 仅用于开发测试,生产环境禁用!**

修改 `src/api/server.rs`:

```rust
// 临时修改为允许所有源
use tower_http::cors::Any;

CorsLayer::new()
    .allow_origin(Any)  // 允许所有源
    .allow_methods(Any)
    .allow_headers(Any)
```

---

### 方案4: 使用浏览器插件 (临时方案)

#### Chrome/Edge插件:
1. **CORS Unblock**
   - 安装: Chrome Web Store搜索 "CORS Unblock"
   - 使用: 点击插件图标启用

2. **Allow CORS**
   - 安装: Chrome Web Store搜索 "Allow CORS"
   - 使用: 点击插件图标启用

#### Firefox插件:
1. **CORS Everywhere**
   - 安装: Firefox Add-ons搜索 "CORS Everywhere"
   - 使用: 点击插件图标启用

**⚠️ 注意**: 
- 仅用于开发测试
- 使用完记得禁用插件
- 不要在生产环境使用

---

### 方案5: 启动Chrome禁用CORS检查 (临时方案)

#### Windows:
```cmd
chrome.exe --disable-web-security --user-data-dir="C:/temp/chrome_dev"
```

#### Mac:
```bash
open -n -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --user-data-dir="/tmp/chrome_dev" --disable-web-security
```

#### Linux:
```bash
google-chrome --disable-web-security --user-data-dir="/tmp/chrome_dev"
```

**⚠️ 警告**: 
- 仅用于开发测试
- 不要用这个浏览器访问其他网站
- 使用完关闭这个浏览器实例

---

## 🔧 验证CORS配置

### 1. 检查服务器日志

启动服务器时会显示CORS配置:

```
INFO defi_hot_wallet::api::server: CORS configured to allow origin: http://localhost:3000
INFO defi_hot_wallet::api::server: Server listening on 127.0.0.1:8888
```

### 2. 测试CORS请求

#### 使用curl测试:

```bash
# 发送OPTIONS预检请求
curl -X OPTIONS http://localhost:8888/api/health \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -v

# 应该看到响应头:
# Access-Control-Allow-Origin: http://localhost:3000
# Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS, PUT, PATCH
# Access-Control-Allow-Headers: authorization, content-type, accept, origin
```

### 3. 浏览器开发者工具

1. 打开浏览器开发者工具 (F12)
2. 切换到 "Network" 标签
3. 发送API请求
4. 查看响应头,应该包含:
   ```
   Access-Control-Allow-Origin: http://localhost:3000
   Access-Control-Allow-Credentials: true
   ```

---

## 📊 常见CORS错误及解决

### 错误1: No 'Access-Control-Allow-Origin' header

**原因**: 服务器未配置CORS或配置错误

**解决**:
```bash
# 确保环境变量正确
export CORS_ALLOW_ORIGIN="http://localhost:3000"

# 重启服务器
bash restart_server.sh
```

---

### 错误2: Origin 'xxx' is not allowed

**原因**: 前端地址与CORS配置不匹配

**解决**:
```bash
# 修改为正确的前端地址
export CORS_ALLOW_ORIGIN="http://localhost:5173"  # 改为实际端口

# 重启服务器
bash restart_server.sh
```

---

### 错误3: Credentials flag is 'true', but 'Access-Control-Allow-Credentials' is not

**原因**: 前端请求带了credentials但服务器未允许

**解决**: 
- 后端已配置 `.allow_credentials(true)`
- 确保重启服务器后生效

---

### 错误4: Method 'XXX' is not allowed by Access-Control-Allow-Methods

**原因**: 请求方法未在CORS配置中

**解决**: 
- 后端已允许 GET, POST, DELETE, OPTIONS, PUT, PATCH
- 如需其他方法,修改 `src/api/server.rs`

---

## 🎯 推荐配置

### 开发环境 (当前配置)

```bash
# 环境变量
CORS_ALLOW_ORIGIN="http://localhost:3000"

# 特点
✅ 安全: 只允许指定源
✅ 完整: 支持所有常用方法和头部
✅ 灵活: 可通过环境变量修改
```

### 生产环境

```bash
# 环境变量
CORS_ALLOW_ORIGIN="https://your-frontend-domain.com"

# 特点
✅ 安全: 只允许生产域名
✅ HTTPS: 使用安全协议
❌ 禁用: 不使用 allow_origin(Any)
```

---

## 📝 快速检查清单

启动服务器前确认:

- [ ] 环境变量 `CORS_ALLOW_ORIGIN` 已设置
- [ ] 前端地址与CORS配置匹配
- [ ] 服务器已重启(修改配置后)
- [ ] 浏览器控制台无CORS错误

---

## 🚀 快速启动

```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"

# 方式1: 使用脚本(推荐,自动配置CORS)
bash wallet_tools.sh
# 选择 "1. 启动服务器"

# 方式2: 手动启动
export CORS_ALLOW_ORIGIN="http://localhost:3000"
cargo run --features test-env --bin hot_wallet
```

---

## 📖 相关文档

- 服务器配置: `服务器配置信息.md`
- 启动指南: `startup-and-testing-guide.md`
- 快速开始: `QUICK_START.md`

---

**CORS已配置完成,直接启动服务器即可!** 🎉

