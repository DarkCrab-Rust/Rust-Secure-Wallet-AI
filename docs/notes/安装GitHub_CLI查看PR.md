# 🔍 使用GitHub CLI查看PR

## 为什么需要GitHub CLI？

Git命令**无法**查看Pull Requests，因为PR是GitHub的网页功能，不是Git的核心功能。

要通过命令行查看PR，需要使用**GitHub CLI (gh)**。

---

## 📥 安装GitHub CLI

### Windows安装方法

#### 方法1：使用winget（推荐）
```powershell
winget install --id GitHub.cli
```

#### 方法2：使用Scoop
```powershell
scoop install gh
```

#### 方法3：下载安装包
访问：https://cli.github.com/
下载Windows安装程序并安装

---

## 🔐 配置GitHub CLI

### 首次使用需要登录

在Git Bash中运行：
```bash
gh auth login
```

按照提示操作：
1. 选择 `GitHub.com`
2. 选择 `HTTPS`
3. 选择 `Login with a web browser`
4. 复制显示的code
5. 在浏览器中打开给出的URL并粘贴code
6. 授权访问

---

## 🚀 查看PR命令

### 基本命令

#### 查看所有PR
```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
gh pr list --state all
```

#### 查看开放的PR
```bash
gh pr list --state open
```

#### 查看已关闭的PR
```bash
gh pr list --state closed
```

#### 查看已合并的PR
```bash
gh pr list --state merged
```

---

## 📊 详细PR信息

### 查看特定PR的详情
```bash
# 查看PR #1的详情
gh pr view 1

# 在浏览器中打开PR #1
gh pr view 1 --web
```

### 查看PR状态
```bash
gh pr status
```

### 查看PR检查状态
```bash
gh pr checks
```

---

## 🎯 常用命令速查

```bash
# 进入项目目录
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet

# 查看所有PR（包括已合并/关闭）
gh pr list --state all

# 查看PR详细信息（带状态、作者、创建时间）
gh pr list --state all --json number,title,state,author,createdAt

# 查看最近5个PR
gh pr list --state all --limit 5

# 搜索特定PR
gh pr list --search "fix test"

# 查看当前仓库所有PR的统计
gh pr status
```

---

## 📋 输出示例

运行 `gh pr list --state all` 后可能看到：

```
#3  docs: 添加完整代码分析报告  merged  2024-01-15
#2  fix: 修复测试问题          merged  2024-01-14
#1  feat: 添加新功能          closed  2024-01-13
```

这就能看到您的3个PR了！

---

## 🆚 对比：浏览器 vs GitHub CLI

| 功能 | 浏览器 | GitHub CLI |
|---|---|---|
| 查看PR列表 | ✅ 直观 | ✅ 快速 |
| 查看PR详情 | ✅ 完整 | ✅ 简洁 |
| 审查代码 | ✅ 方便 | ⚠️ 基础 |
| 创建PR | ✅ 易用 | ✅ 高效 |
| 合并PR | ✅ 直观 | ✅ 快速 |
| **推荐场景** | 详细审查 | 快速查询 |

---

## 🎯 推荐方案

### 对于查看PR：

#### 🥇 首选：浏览器
```
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/pulls
```
- 最直观
- 功能最全
- 无需额外安装

#### 🥈 备选：GitHub CLI
```bash
gh pr list --state all
```
- 命令行操作
- 快速查询
- 适合脚本自动化

---

## 💡 解决您的问题

### 您的3个PR在哪里？

运行以下命令之一：

#### 选项1：浏览器（最简单）
```
直接访问：https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/pulls
在搜索框删除 is:open，只保留 is:pr
```

#### 选项2：GitHub CLI（如果已安装）
```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
gh pr list --state all
```

#### 选项3：Git分支（查看PR对应的分支）
```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
bash 完整检查仓库.sh
```
这会显示所有远程分支，PR对应的分支可能还在。

---

## 🔧 创建新PR（使用GitHub CLI）

```bash
# 创建新分支
git checkout -b feature/new-feature

# 提交更改
git add .
git commit -m "feat: 添加新功能"

# 推送到GitHub
git push origin feature/new-feature

# 使用gh创建PR
gh pr create --title "添加新功能" --body "详细描述"

# 或交互式创建
gh pr create
```

---

## 📝 总结

### 要查看PR，您有3个选择：

1️⃣ **浏览器访问**（最推荐）
```
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/pulls
```

2️⃣ **安装GitHub CLI**
```bash
winget install --id GitHub.cli
gh auth login
gh pr list --state all
```

3️⃣ **查看Git分支**（间接方法）
```bash
bash 完整检查仓库.sh
```

---

**现在选择一个方法，找到您的3个PR！** 🚀

