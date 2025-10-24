# 删除GitHub无用分支

## 🎯 目标

删除GitHub上所有无用的分支，只保留main分支。

---

## 🗑️ 需要删除的分支

根据您的GitHub截图，您有10个分支，除了main都可以删除：

1. ❌ `archive-bridge-stub` - 归档分支
2. ❌ `功能/API改进` - 功能分支
3. ❌ `功能/api改进-修复` - 功能分支
4. ❌ `功能/ci-tests-secretvec` - 功能分支
5. ❌ `功能/cli-secretvec` - 功能分支
6. ❌ `功能/加密-secretvec` - 功能分支
7. ❌ `特性/新功能` - 功能分支
8. ❌ `功能/secretvec-foundation` - 功能分支
9. ❌ `安全/secretvec-ci` - 安全分支
10. ✅ `main` - **保留此分支**

---

## 🔧 删除分支的方法

### 方法1：在GitHub网页上删除（推荐）⭐⭐⭐⭐⭐

#### 步骤：
1. 访问分支页面：
   ```
   https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/branches
   ```

2. 找到要删除的分支

3. 点击每个分支旁边的垃圾桶图标 🗑️

4. 确认删除

**重复以上步骤，删除除main外的所有分支。**

---

### 方法2：使用Git命令删除

#### 在Git Bash中执行：

```bash
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet

# 删除archive-bridge-stub分支
git push origin --delete archive-bridge-stub

# 删除其他功能分支
git push origin --delete 功能/API改进
git push origin --delete 功能/api改进-修复
git push origin --delete 功能/ci-tests-secretvec
git push origin --delete 功能/cli-secretvec
git push origin --delete 功能/加密-secretvec
git push origin --delete 特性/新功能
git push origin --delete 功能/secretvec-foundation
git push origin --delete 安全/secretvec-ci
```

---

### 方法3：批量删除脚本

创建一个脚本批量删除：

```bash
#!/bin/bash
# 删除所有无用分支

cd "$(dirname "$0")"

echo "删除GitHub上的无用分支..."

# 要删除的分支列表
branches=(
    "archive-bridge-stub"
    "功能/API改进"
    "功能/api改进-修复"
    "功能/ci-tests-secretvec"
    "功能/cli-secretvec"
    "功能/加密-secretvec"
    "特性/新功能"
    "功能/secretvec-foundation"
    "安全/secretvec-ci"
)

for branch in "${branches[@]}"; do
    echo "删除分支: $branch"
    git push origin --delete "$branch"
    if [ $? -eq 0 ]; then
        echo "✅ 删除成功: $branch"
    else
        echo "❌ 删除失败: $branch (可能已不存在)"
    fi
    echo ""
done

echo "✅ 所有分支删除完成！"
echo "现在只保留main分支"
```

保存为 `删除所有无用分支.sh`，然后执行：
```bash
bash 删除所有无用分支.sh
```

---

## 🎯 删除本地分支（可选）

如果您本地也有这些分支，可以删除：

```bash
# 查看本地所有分支
git branch

# 删除本地分支（如果有）
git branch -d archive-bridge-stub
git branch -d 功能/API改进
# ... 其他分支
```

---

## ✅ 验证删除结果

### 访问分支页面：
```
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/branches
```

应该只看到：
```
✅ main (1个分支)
```

---

## 🎯 设置main为默认分支

删除其他分支后，确保main是默认分支：

### 步骤：
1. 访问仓库设置：
   ```
   https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/settings/branches
   ```

2. 在 "Default branch" 部分

3. 如果不是main，点击切换按钮

4. 选择 **main**

5. 点击 "Update" 保存

---

## 📋 删除顺序建议

### 第一步：强制覆盖main分支
```bash
bash 🔥_强制覆盖GitHub主分支.sh
```

### 第二步：设置main为默认分支
访问设置页面，设置main为默认分支

### 第三步：删除其他分支
使用网页或命令删除所有其他分支

### 第四步：验证
访问仓库，确认只有main分支

---

## ⚠️ 注意事项

### 删除前确认：
- ✅ main分支已包含所有需要的代码
- ✅ main分支已成功推送到GitHub
- ✅ 其他分支确实不需要了

### 删除后：
- ✅ 只保留main分支
- ✅ 仓库结构清晰
- ✅ 避免混淆

---

## 🚀 完整操作流程

### 1. 覆盖main分支
```bash
bash 🔥_强制覆盖GitHub主分支.sh
```

### 2. 设置默认分支
访问：https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/settings/branches

### 3. 删除其他分支
访问：https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/branches
或使用命令批量删除

### 4. 验证结果
访问：https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet

应该看到：
- ✅ 只有main分支
- ✅ 所有文件都在
- ✅ 代码与本地一致

---

**现在先执行强制覆盖脚本，然后再删除其他分支！** 🚀

