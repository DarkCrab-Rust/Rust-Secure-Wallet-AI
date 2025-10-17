# Security Notes

This project prioritizes safe key handling, standards-compliant transactions, and verifiable audit trails. This document summarizes the key mechanisms and related controls.

## Envelope Encryption for Wallet Data

- Master key: WALLET_ENC_KEY (base64-encoded 32 bytes) provided via environment.
- Per-wallet encryption:
  - Random 16-byte salt per wallet.
  - HKDF-SHA256 derives an AES-256-GCM key from WALLET_ENC_KEY with the salt.
  - AAD (Associated Authenticated Data): wallet name.
  - Ciphertext + salt stored; secrets are zeroized in memory.

Set the key in environment before running:

- PowerShell: $env:WALLET_ENC_KEY = "<base64-32-bytes>"
- Bash: export WALLET_ENC_KEY="<base64-32-bytes>"

## Ethereum Address Derivation

- Derive secp256k1 key (k256) → uncompressed SEC1 public key.
- Keccak256 over the 64-byte X||Y (no 0x04 prefix); take last 20 bytes.
- Address is 0x-prefixed hex of those 20 bytes.

## EIP-1559 (Type-2) Transactions

- Ethereum client constructs Eip1559TransactionRequest with chain_id.
- Fees default from gas_price when needed; chain_id enforced to prevent replay.

## Audit Log Integrity (HMAC)

- Each audit row stores HMAC-SHA256 over canonical fields.
- HMAC key derived from WALLET_ENC_KEY; verified on retrieval to detect tampering.

## Bridge Mocks Guard (Production Safety)

- In test builds (feature `test-env`), mocks are allowed automatically.
- Outside tests, mocks require the explicit guard:
  - Set `ALLOW_BRIDGE_MOCKS=1` AND one of:
    - `BRIDGE_MOCK_FORCE_SUCCESS=1` (or empty)
    - `BRIDGE_MOCK=1`
    - `FORCE_BRIDGE_SUCCESS=1`
    - `BRIDGE_MOCK_FORCE=1`
- If mocks are requested without `ALLOW_BRIDGE_MOCKS=1`, server startup fails fast with a clear error.

## API Auth Header

- When API_KEY is configured, clients must send header `Authorization: <API_KEY>`.
- No "Bearer" prefix parsing; values are compared in constant time via digest.

## Test Environment

- Under feature `test-env`, tests set deterministic env vars for stable behavior:
  - WALLET_ENC_KEY (all-zero placeholder for tests)
  - BRIDGE_MOCK_FORCE_SUCCESS=1, BRIDGE_MOCK=1
  - ALLOW_BRIDGE_MOCKS=1
- Do not use these values in production.

## Optional PKCS#11 advisory

- This repository declares `pkcs11 = { version = "0.5.0", optional = true }` and exposes a feature `pkcs11-backend` to enable it.
- There is an advisory RUSTSEC-2022-0034 (safety issues in `pkcs11`). Because `pkcs11` is optional and only enabled by feature, CI is configured to ignore this advisory by default. Review this advisory carefully before enabling `pkcs11-backend` in production builds.

Guidance:

- If you enable `pkcs11-backend`, prefer to pin and audit the dependency and test on target platforms that provide PKCS#11 implementations.
- If you need help upgrading or removing the optional dependency, open an issue/PR and tag it with `security`.
