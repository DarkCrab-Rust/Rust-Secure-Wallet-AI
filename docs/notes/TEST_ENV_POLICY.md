Test environment policy

This repository uses a dedicated `test-env` feature to enable deterministic test-only environment variables and defaults. The goal is to keep any insecure placeholders or deterministic keys out of production binaries and CI workflow files.

Rules
- Do NOT commit plaintext or deterministic test keys to workflow YAML files or source files that can be included in production builds.
- If a test requires deterministic environment variables, gate that behavior behind the `test-env` feature and ensure the file that injects those defaults is annotated with `#![cfg(any(test, feature = "test-env"))]`.
- For CI runs that require deterministic test keys, use the `--features test-env` flag on `cargo test`, or inject secrets via repository secrets (recommended).
- Avoid creating files or writing to GITHUB_ENV inside workflows that inject plaintext keys.

Examples
- Good: `cargo test --features test-env`
- Bad: echoing WALLET_ENC_KEY into $GITHUB_ENV in a workflow

If you're unsure, open a PR and tag the security/ops team for review.
