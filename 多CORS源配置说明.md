# 🌐 多CORS源配置说明

## ✅ 后端已支持多个CORS源!

后端代码已经实现了多CORS源支持,可以同时允许多个前端地址访问。

---

## 🎯 使用方法

### 方式1: 单个源 (默认)

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000"
bash restart_server.sh
```

**效果**: 只允许 `http://localhost:3000` 访问

---

### 方式2: 多个源 (推荐)

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"
bash restart_server.sh
```

**效果**: 同时允许 `http://localhost:3000` 和 `http://localhost:3010` 访问

**用途**:
- `3000端口`: 后端团队测试
- `3010端口`: 前端开发联调

---

### 方式3: 修改启动脚本 (永久配置)

编辑 `restart_server.sh`,将第40行改为:

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"
```

---

## 📋 配置示例

### 示例1: 开发环境 (多个本地端口)

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010,http://localhost:5173"
```

**允许**:
- 3000: 后端测试
- 3010: 前端开发
- 5173: Vite开发服务器

---

### 示例2: 测试环境

```bash
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://test.example.com"
```

**允许**:
- localhost:3000: 本地测试
- test.example.com: 测试服务器

---

### 示例3: 生产环境 (单个源)

```bash
export CORS_ALLOW_ORIGIN="https://app.example.com"
```

**允许**:
- 仅生产域名

---

## 🔧 实现原理

后端代码会自动检测CORS配置:

```rust
// src/api/server.rs (第109-125行)
.allow_origin({
    let origins_env = cors_origin;
    if origins_env.contains(',') {
        // 多个源: 按逗号分割
        let list = origins_env
            .split(',')
            .map(|s| s.trim())
            .filter(|s| !s.is_empty())
            .map(|s| HeaderValue::from_str(s))
            .collect();
        AllowOrigin::list(list)
    } else {
        // 单个源
        AllowOrigin::exact(HeaderValue::from_str(&origins_env))
    }
})
```

**特点**:
- ✅ 自动检测逗号分隔
- ✅ 自动去除空格
- ✅ 支持任意数量的源
- ✅ 向后兼容单源配置

---

## 🚀 推荐配置

### 开发阶段

```bash
# 同时支持后端测试和前端开发
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"
bash restart_server.sh
```

**优点**:
- 后端团队可以在3000端口测试
- 前端团队可以在3010端口开发
- 互不干扰

---

### 生产环境

```bash
# 只允许生产域名
export CORS_ALLOW_ORIGIN="https://your-production-domain.com"
bash restart_server.sh
```

**优点**:
- 安全性高
- 只允许指定域名

---

## 📊 配置对比

| 配置 | 单源 | 多源 | 推荐场景 |
|------|------|------|---------|
| `http://localhost:3000` | ✅ | ❌ | 仅后端测试 |
| `http://localhost:3010` | ✅ | ❌ | 仅前端开发 |
| `http://localhost:3000,http://localhost:3010` | ❌ | ✅ | **开发环境推荐** |
| `https://app.example.com` | ✅ | ❌ | 生产环境 |

---

## 🔍 验证配置

### 1. 查看服务器日志

启动服务器后,日志会显示:

```
INFO defi_hot_wallet::api::server: CORS configured to allow origin: http://localhost:3000,http://localhost:3010
```

### 2. 测试CORS请求

```bash
# 测试3000端口
curl -v -X OPTIONS http://localhost:8888/api/health \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET"

# 测试3010端口
curl -v -X OPTIONS http://localhost:8888/api/health \
  -H "Origin: http://localhost:3010" \
  -H "Access-Control-Request-Method: GET"
```

两个请求都应该返回:
```
< Access-Control-Allow-Origin: http://localhost:3000
或
< Access-Control-Allow-Origin: http://localhost:3010
```

---

## 🎯 快速配置命令

### 配置多CORS源并启动

```bash
cd "C:/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet"

# 设置多个CORS源
export CORS_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3010"

# 重启服务器
bash restart_server.sh
```

### 使用一键启动脚本

```bash
bash start_fullstack.sh
# 选择 "2. 启动后端+前端"
# 会自动配置CORS为3010
```

---

## 📝 注意事项

1. **逗号分隔**: 多个源用逗号分隔,不要用分号或其他符号
2. **无空格**: 虽然代码会自动去除空格,但建议不要添加多余空格
3. **完整URL**: 必须包含协议 (`http://` 或 `https://`)
4. **端口号**: 必须包含端口号 (如 `:3000`)
5. **生产环境**: 生产环境建议只配置单个域名

---

## 📖 相关文档

- `CORS配置说明.md` - CORS详细配置
- `故障处理指南.md` - CORS错误处理
- `后端测试指南.md` - 后端测试方法

---

**后端已完美支持多CORS源!** 🎉

