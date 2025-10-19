# Changelog

## 2025-10-16 — Security hardening and dependency fixes

This repository received targeted security hardening focused on private key management,
derivation correctness, and minimizing vulnerable transitive dependencies.

Changes made:

- Replace custom Ethereum BIP32 derivation with `coins-bip32` for canonical BIP32 behavior.
  - Added unit tests to validate parity for BIP44 (m/44'/60'/0'/0/0) against `coins-bip32`.
  - File: `src/core/wallet_manager.rs`, tests in `src/core/*_bip44_tests.rs`.

- Harden backup export endpoint `/api/wallets/:name/backup` (production-only):
  - Requires environment `BACKUP_ENABLED=1` (existing guard) and an explicit operator approval
    header `X-Backup-Approve: 1` (or `true`).
  - Backups are encrypted with AES-256-GCM under `WALLET_BACKUP_KEY` (base64 32 bytes).
  - Returned value is base64(nonce || ciphertext) in the existing `BackupResponse.seed_phrase`.
  - In test mode (`--features test-env`), backwards-compatible plaintext mnemonic is returned
    for deterministic tests.
  - File: `src/api/server.rs`.

- Removed `slip10` crate dependency and implemented a minimal local SLIP-0010 hardened-only
  derivation for ed25519 to avoid pulling older `ed25519-dalek`/`curve25519-dalek` versions.
  - File: `src/core/wallet_manager.rs` (local SLIP-0010 implementation for Solana derivation).

- Fixed Clippy issues and eliminated warnings triggered by `cargo clippy --features test-env -- -D warnings`.
  - Example fixes: removed unused imports, fixed needless borrows, small cleanups.

- Ran `cargo audit` and resolved high-severity advisories found via dependency upgrades and
  local changes. Current remaining advisory: an `unsound` warning on the optional `pkcs11` crate
  (used only behind the optional `pkcs11-backend` feature). This crate is optional; consider
  removing or replacing it if you enable the feature in production.

Notes & operational guidance:

- CI: add `cargo clippy --features test-env -- -D warnings` and `cargo audit` to CI pipeline. Block
  merges on warnings/vulnerabilities.
- Backup KEK management: provision `WALLET_BACKUP_KEY` securely (HSM/secret manager), rotate KEK
  periodically, and ensure strict operator authentication/authorization for the approval header.
- If you intend to enable the `pkcs11-backend` feature, review the `pkcs11` crate advisory and
  consider alternative providers or a vetted PKCS#11 wrapper.

If you want, I can:
- Add a short CI workflow that runs clippy and cargo-audit and fails on warnings/advisories.
- Implement a structured encrypted backup response (include version, algorithm, nonce, and kek_id)
  rather than embedding base64 into `seed_phrase`.
