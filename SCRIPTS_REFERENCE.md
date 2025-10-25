# 🎯 DeFi热钱包 - 脚本快速参考

## 🚀 快速启动

```bash
# 方式1: 使用主菜单 (推荐)
bash wallet_tools.sh

# 方式2: 直接运行脚本
bash start_and_test.sh
```

---

## 📋 完整脚本列表

### 🎯 主菜单
```bash
bash wallet_tools.sh
```
**功能**: 交互式菜单,访问所有工具

---

### 🚀 服务器管理

#### 1. 启动服务器
```bash
bash start_server.sh
```
**功能**:
- ✅ 检查端口占用
- ✅ 设置环境变量
- ✅ 启动服务器(前台运行)

**使用场景**: 首次启动或需要查看实时日志

---

#### 2. 重启服务器
```bash
bash restart_server.sh
```
**功能**:
- ✅ 停止现有服务器
- ✅ 清理端口
- ✅ 启动新服务器(后台运行)
- ✅ 验证启动成功

**使用场景**: 修改代码后重启,或服务器异常时

---

#### 3. 管理服务器
```bash
bash manage_server.sh
```
**功能**:
- ✅ 查看服务器状态
- ✅ 停止服务器
- ✅ 查看重启指令
- ✅ 查看测试日志

**使用场景**: 日常管理和监控

---

#### 4. 查看服务器日志
```bash
bash view_server_logs.sh
```
**功能**:
- ✅ 查看最新日志
- ✅ 实时跟踪日志
- ✅ 搜索日志内容
- ✅ 列出所有日志文件

**使用场景**: 调试问题,查看服务器运行状态

---

### 🧪 测试工具

#### 5. 快速测试
```bash
bash quick_test.sh
```
**功能**:
- ✅ 测试所有API (1次)
- ✅ 6项完整测试
- ✅ 显示成功率

**使用场景**: 验证服务器功能,快速检查

**前提**: 服务器必须已启动

---

#### 6. 启动并测试
```bash
bash start_and_test.sh
```
**功能**:
- ✅ 自动启动服务器(后台)
- ✅ 等待服务器就绪
- ✅ 运行快速测试
- ✅ 显示结果

**使用场景**: 一键完成所有操作,最方便!

---

#### 7. 7天自动化测试
```bash
bash week_automated_test_final.sh
```
**功能**:
- ✅ 7天持续测试
- ✅ 每30分钟测试一次
- ✅ 336轮测试
- ✅ 详细日志记录

**使用场景**: 长期稳定性测试

**前提**: 服务器必须已启动

---

### 🛠️ 维护工具

#### 8. 清理仓库
```bash
bash cleanup_repo.sh
```
**功能**:
- ✅ 删除备份目录
- ✅ 删除IDE配置
- ✅ 删除数据库文件
- ✅ 删除测试产物
- ✅ 清理构建产物

**使用场景**: 提交代码前清理,释放空间

---

#### 9. 完整文档
```bash
cat startup-and-testing-guide.md
```
**功能**:
- ✅ 详细的启动指令
- ✅ 测试命令示例
- ✅ 故障排查指南
- ✅ API响应示例

**使用场景**: 查看详细文档和命令

---

## 🎯 常用场景

### 场景1: 第一次使用
```bash
# 1. 启动主菜单
bash wallet_tools.sh

# 2. 选择 "6. 启动并测试"
# 3. 查看测试结果
```

---

### 场景2: 日常开发
```bash
# 1. 启动服务器
bash start_server.sh

# 2. 在新终端运行测试
bash quick_test.sh

# 3. 修改代码后重启
bash restart_server.sh
```

---

### 场景3: 调试问题
```bash
# 1. 查看服务器状态
bash manage_server.sh
# 选择 "1. 查看服务器状态"

# 2. 查看日志
bash view_server_logs.sh
# 选择 "5. 实时跟踪日志"

# 3. 重启服务器
bash restart_server.sh
```

---

### 场景4: 长期测试
```bash
# 1. 启动服务器
bash start_server.sh

# 2. 在新终端运行7天测试
bash week_automated_test_final.sh

# 3. 查看测试日志
bash manage_server.sh
# 选择 "4. 查看测试日志"
```

---

### 场景5: 提交代码前
```bash
# 1. 运行快速测试
bash quick_test.sh

# 2. 清理仓库
bash cleanup_repo.sh

# 3. 提交代码
git add .
git commit -m "your message"
git push
```

---

## 📊 脚本对比

| 脚本 | 启动服务器 | 运行测试 | 后台运行 | 交互式 |
|------|-----------|---------|---------|--------|
| `start_server.sh` | ✅ | ❌ | ❌ | ❌ |
| `restart_server.sh` | ✅ | ❌ | ✅ | ❌ |
| `start_and_test.sh` | ✅ | ✅ | ✅ | ❌ |
| `quick_test.sh` | ❌ | ✅ | - | ❌ |
| `week_automated_test_final.sh` | ❌ | ✅ | - | ❌ |
| `manage_server.sh` | ❌ | ❌ | - | ✅ |
| `view_server_logs.sh` | ❌ | ❌ | - | ✅ |
| `cleanup_repo.sh` | ❌ | ❌ | - | ✅ |
| `wallet_tools.sh` | - | - | - | ✅ |

---

## 🔧 环境变量

所有脚本使用相同的环境变量:

```bash
WALLET_ENC_KEY="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
API_KEY="testnet_api_key_51a69b550a2c4149"
CORS_ALLOW_ORIGIN="http://localhost:3000"
DATABASE_URL="sqlite://./data/testnet_wallet.db?mode=rwc"
RUST_LOG="info"
SERVER_HOST="127.0.0.1"
SERVER_PORT="8888"
TEST_SKIP_DECRYPT="1"
ALLOW_BRIDGE_MOCKS="1"
```

---

## 📂 日志文件位置

```
logs/
├── server_YYYYMMDD_HHMMSS.log      # 服务器日志
└── week_test/
    └── automated_test_YYYYMMDD_HHMMSS.log  # 测试日志
```

---

## 🚨 常见问题

### Q1: 端口8888被占用?
```bash
# 方案1: 使用restart_server.sh自动处理
bash restart_server.sh

# 方案2: 手动停止
bash manage_server.sh
# 选择 "2. 停止服务器"
```

---

### Q2: 测试失败?
```bash
# 1. 检查服务器是否运行
bash manage_server.sh

# 2. 查看服务器日志
bash view_server_logs.sh

# 3. 重启服务器
bash restart_server.sh

# 4. 重新测试
bash quick_test.sh
```

---

### Q3: 如何停止7天测试?
```
按 Ctrl+C 即可停止
```

---

### Q4: 如何查看实时日志?
```bash
bash view_server_logs.sh
# 选择 "5. 实时跟踪日志"
# 按 Ctrl+C 停止跟踪
```

---

## 💡 最佳实践

1. **日常使用**: 使用 `wallet_tools.sh` 主菜单
2. **快速测试**: 使用 `start_and_test.sh` 一键完成
3. **开发调试**: 使用 `start_server.sh` 查看实时日志
4. **长期测试**: 使用 `week_automated_test_final.sh`
5. **提交前**: 运行 `cleanup_repo.sh` 清理仓库

---

## 🎓 学习路径

### 新手 → 熟练 → 专家

**新手** (第1天):
```bash
bash wallet_tools.sh  # 使用主菜单
```

**熟练** (第2-7天):
```bash
bash start_and_test.sh  # 一键启动测试
bash quick_test.sh      # 快速验证
```

**专家** (第8天+):
```bash
# 根据需求选择合适的脚本
bash start_server.sh           # 需要查看日志
bash restart_server.sh         # 快速重启
bash view_server_logs.sh       # 调试问题
bash week_automated_test_final.sh  # 长期测试
```

---

## 📞 获取帮助

查看完整文档:
```bash
cat startup-and-testing-guide.md
```

或使用主菜单:
```bash
bash wallet_tools.sh
# 选择 "9. 查看完整文档"
```

---

**🎉 祝使用愉快!**

