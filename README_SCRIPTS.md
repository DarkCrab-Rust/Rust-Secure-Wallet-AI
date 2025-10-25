# 🎯 脚本工具完整指南

## 📚 文档索引

| 文档 | 说明 | 适合人群 |
|------|------|---------|
| `命令速查表.md` | 超简洁版本 | ⭐ 所有人 |
| `快速命令.txt` | 纯文本格式 | 复制粘贴 |
| `脚本使用手册.md` | 中等详细 | 日常使用 |
| `QUICK_START.md` | 快速开始 | 新手 |
| `SCRIPTS_REFERENCE.md` | 完整参考 | 深入学习 |
| `startup-and-testing-guide.md` | 启动指南 | 详细操作 |

---

## 🚀 快速开始

### 方式1: 主菜单 (推荐新手)
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"
bash wallet_tools.sh
```

### 方式2: 一键启动测试 (推荐日常)
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"
bash start_and_test.sh
```

---

## 📋 脚本分类

### 🎯 主菜单 (1个)
- `wallet_tools.sh` - 交互式菜单

### 🚀 服务器管理 (4个)
- `start_server.sh` - 启动服务器
- `restart_server.sh` - 重启服务器
- `manage_server.sh` - 管理服务器
- `view_server_logs.sh` - 查看日志

### 🧪 测试工具 (3个)
- `quick_test.sh` - 快速测试
- `start_and_test.sh` - 启动+测试 ⭐
- `week_automated_test_final.sh` - 7天测试

### 🛠️ 维护工具 (2个)
- `cleanup_repo.sh` - 清理仓库
- `list_scripts.sh` - 列出脚本

**总计: 10个脚本**

---

## 💡 使用建议

| 场景 | 推荐脚本 |
|------|---------|
| 第一次使用 | `wallet_tools.sh` |
| 日常开发 | `start_and_test.sh` ⭐ |
| 快速测试 | `quick_test.sh` |
| 调试问题 | `view_server_logs.sh` |
| 重启服务器 | `restart_server.sh` |
| 停止服务器 | `manage_server.sh` |
| 长期测试 | `week_automated_test_final.sh` |
| 提交前清理 | `cleanup_repo.sh` |

---

## 🔧 服务器信息

```
地址: http://localhost:8888
API密钥: testnet_api_key_51a69b550a2c4149
端口: 8888
```

---

## 📂 项目结构

```
Rust-Blockchain-Secure-Wallet/
│
├── 🎯 主菜单
│   └── wallet_tools.sh
│
├── 🚀 服务器管理
│   ├── start_server.sh
│   ├── restart_server.sh
│   ├── manage_server.sh
│   └── view_server_logs.sh
│
├── 🧪 测试工具
│   ├── quick_test.sh
│   ├── start_and_test.sh
│   └── week_automated_test_final.sh
│
├── 🛠️ 维护工具
│   ├── cleanup_repo.sh
│   └── list_scripts.sh
│
└── 📖 文档
    ├── README_SCRIPTS.md (本文件)
    ├── 命令速查表.md
    ├── 快速命令.txt
    ├── 脚本使用手册.md
    ├── QUICK_START.md
    ├── SCRIPTS_REFERENCE.md
    └── startup-and-testing-guide.md
```

---

## 🎓 学习路径

### 第1天: 新手入门
```bash
# 1. 查看速查表
cat 命令速查表.md

# 2. 使用主菜单
bash wallet_tools.sh
```

### 第2-7天: 熟练使用
```bash
# 直接使用常用命令
bash start_and_test.sh
bash quick_test.sh
```

### 第8天+: 专家级
```bash
# 根据需求选择合适的脚本
bash restart_server.sh
bash view_server_logs.sh
bash week_automated_test_final.sh
```

---

## 🚨 常见问题

### Q1: 不知道用哪个脚本?
**A**: 使用主菜单 `bash wallet_tools.sh`

### Q2: 想快速启动测试?
**A**: 使用 `bash start_and_test.sh`

### Q3: 服务器已运行,只想测试?
**A**: 使用 `bash quick_test.sh`

### Q4: 如何查看日志?
**A**: 使用 `bash view_server_logs.sh`

### Q5: 端口被占用?
**A**: 使用 `bash restart_server.sh` 自动处理

---

## 📞 获取帮助

### 查看简洁版
```bash
cat 命令速查表.md
```

### 查看详细版
```bash
cat SCRIPTS_REFERENCE.md
```

### 查看完整指南
```bash
cat startup-and-testing-guide.md
```

---

## ✅ 检查脚本完整性

```bash
bash list_scripts.sh
```

---

**🎉 开始使用吧!**

推荐从这里开始:
```bash
cd "C:\Users\plant\Desktop\Rust区块链\Rust-Blockchain-Secure-Wallet"
bash wallet_tools.sh
```

