# 🔧 彻底解决PowerShell编码问题

## 🎯 问题根源

PowerShell在处理UTF-8编码的中文字符时存在兼容性问题，导致无法正确执行bash命令和脚本。

---

## ✅ 终极解决方案

### 方案1：完全使用Git Bash（最推荐）⭐⭐⭐⭐⭐

**永久放弃PowerShell，只使用Git Bash！**

#### 步骤：
1. 打开 **Git Bash**（不是PowerShell）
2. 执行所有命令

#### 优势：
- ✅ 完美支持UTF-8
- ✅ 原生支持bash脚本
- ✅ 无编码问题
- ✅ 与Linux命令完全兼容

---

### 方案2：在PowerShell中设置UTF-8编码

如果您必须使用PowerShell，在每次打开PowerShell时先执行：

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001
```

然后再执行其他命令。

#### 缺点：
- ❌ 每次都要设置
- ❌ 不稳定
- ❌ 仍可能出现问题

---

### 方案3：创建PowerShell配置文件（一次性设置）

```powershell
# 检查是否有配置文件
Test-Path $PROFILE

# 如果返回False，创建配置文件
New-Item -Path $PROFILE -Type File -Force

# 编辑配置文件
notepad $PROFILE
```

在打开的记事本中添加：
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
Set-Alias -Name bash -Value "C:\Program Files\Git\bin\bash.exe"
```

保存后，重启PowerShell。

---

## 🚀 现在立即执行（使用Git Bash）

### 在Git Bash中运行以下命令：

```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
bash 完整检查仓库.sh
```

这个脚本会：
1. ✅ 检查远程仓库连接
2. ✅ 获取最新信息
3. ✅ 显示所有分支
4. ✅ 对比本地和远程差异
5. ✅ 显示提交历史
6. ✅ 检查工作区状态
7. ✅ 给出下一步建议
8. ✅ 解释PR查看方法

---

## 📋 Git Bash vs PowerShell 对比

| 功能 | Git Bash | PowerShell |
|---|---|---|
| UTF-8支持 | ✅ 完美 | ❌ 有问题 |
| Bash脚本 | ✅ 原生支持 | ❌ 需要额外配置 |
| Git命令 | ✅ 完美 | ✅ 可用 |
| Linux命令 | ✅ 支持 | ❌ 不支持 |
| 中文显示 | ✅ 完美 | ❌ 经常乱码 |
| **推荐度** | ⭐⭐⭐⭐⭐ | ⭐⭐ |

---

## 🎯 推荐工作流程

### 日常开发（全部使用Git Bash）

```bash
# 1. 打开Git Bash

# 2. 进入项目目录
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet

# 3. 检查仓库状态
bash 完整检查仓库.sh

# 4. 提交更改
bash fix_and_commit.sh

# 5. 运行测试
cargo test --lib --bins -- --test-threads=20
```

---

## 💡 为什么会有PowerShell编码问题？

### 技术原因：
1. **历史遗留**：PowerShell最初设计时主要面向英文用户
2. **编码不一致**：Windows系统编码（GBK）vs Git/Bash编码（UTF-8）
3. **Cursor工具调用**：Cursor调用PowerShell时可能使用了错误的编码设置

### 解决原理：
- Git Bash使用MinGW环境，原生UTF-8
- 完全绕过PowerShell的编码转换
- 直接使用Linux风格的bash环境

---

## 🔍 检查GitHub PR的正确方法

### 问题：为什么Git命令看不到PR？

**因为PR是GitHub网页功能，不是Git功能！**

Git只能看到：
- ✅ 分支（branches）
- ✅ 提交（commits）
- ✅ 标签（tags）

Git看不到：
- ❌ Pull Requests
- ❌ Issues
- ❌ GitHub Actions
- ❌ 项目看板

### 查看PR的方法：

#### 方法1：浏览器访问
```
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/pulls
```

#### 方法2：使用GitHub CLI
```bash
# 安装GitHub CLI
# 访问：https://cli.github.com/

# 安装后运行
gh auth login
gh pr list --repo Yinhang3377/Rust-Blockchain-Secure-Wallet --state all
```

---

## ⚡ 立即执行的命令

### 打开Git Bash，复制粘贴：

```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet && bash 完整检查仓库.sh
```

---

## 🎉 总结

### 最佳实践：
1. ✅ **永远使用Git Bash**（不要用PowerShell）
2. ✅ **所有脚本都是.sh格式**
3. ✅ **删除所有.bat文件**（已完成）
4. ✅ **使用浏览器查看PR**

### 为什么这样做：
- 🚫 避免编码问题
- 🚫 避免兼容性问题
- ✅ 提高效率
- ✅ 稳定可靠

---

**现在打开Git Bash，开始使用吧！** 🚀

```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
bash 完整检查仓库.sh
```

