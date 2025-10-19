# 贡献指南

- 代码风格遵循 rustfmt/clippy
- 提交前请补充单元测试
- 详细描述 PR 内容
- 参考 docs/ 及 README


- 代码风格遵循 rustfmt/clippy
- 提交前请补充单元测试
- 详细描述 PR 内容
- 参考 docs/ 及 README

## 测试与 CI（简短说明）

本仓库在测试和持续集成上有两个重要约定，用来减少测试抖动并保护密钥材料：

- 测试环境助手：所有需要可预测/确定性密钥或绕过生产加密限制的测试，应调用 `tests::util::set_test_env()`。该辅助函数会设置一个确定性的测试主密钥（base64 格式的 32 字节全零），并开启测试标志（如 `TEST_SKIP_DECRYPT=1`、`ALLOW_BRIDGE_MOCKS=1`）。请不要在测试中直接硬编码或散布 `WALLET_ENC_KEY`/其他敏感环境变量，统一使用此 helper 能减少摩擦并让 CI 一致。

- CI 策略要点：
  - CI 会运行一个“policy-check”步骤，用来检测不安全的模式（例如在非测试路径中打印秘密、直接在代码里写死 WALLET_ENC_KEY 等）。仓库中有意的、受控的测试用例（例如 `tests/util.rs`、`src/test_env.rs`、`src/api/server.rs` 的测试构造器）在策略中被允许。
  - CI 还会运行 `cargo clippy`（默认 feature 集合）和完整测试套件（使用 `tests::util::set_test_env()` 环境），确保代码质量和测试的可重复性。

- cargo-audit（建议）：我们建议在本地或 CI 中定期运行 `cargo audit` 来检测依赖的已知漏洞。已经将此项加入任务队列（见仓库 TODO）；如果 `cargo audit` 报告高严重性问题，请在 PR 中一并说明如何修复或规避。

短说明：在向仓库提交与密钥/加密有关的变更时，优先考虑不改变生产行为（使用测试构造器或运行时开关），并为修改添加或更新测试以覆盖边界情况。

## 清理被跟踪的测试工件（快速命令）

如果误将测试构建产物（如 `target_test_*`）提交到了仓库，请按下面步骤清理（在本地运行）：

```bash
# 从索引中移除已被跟踪的测试工件，但保留文件在工作区（推荐）
git rm --cached -r -- "target_test_*" || true
git rm --cached -r -- target/**/target_test_* || true

# 提交移除并推送
git commit -m "chore: remove tracked test artifacts (target_test_*)" || true
git push

# 清理本地构建产物
cargo clean
``` 

这些命令会把被跟踪的测试工件从 git 索引中移除，并提示你提交更改。CI 的 policy-check 会在 PR 中阻止再次提交这些文件。
``` 
# 贡献指南

- 代码风格遵循 rustfmt/clippy
- 提交前请补充单元测试
- 详细描述 PR 内容
- 参考 docs/ 及 README
