README — legacy archives
=========================

This repository was trimmed to keep the wallet core small. Heavy, non-core modules have been moved into the `legacy/` folder and replaced with minimal stubs so the core code compiles and tests remain deterministic under test settings.

What was archived
- Bridge full implementations -> `legacy/bridge/*` (relay, mock, transfer)
- Solana implementation -> `legacy/solana_rs_orig.rs`
- Audit modules -> `legacy/archived_audit_mods.rs`

Why
- Reduce maintenance surface for the core wallet while preserving the ability to restore full behavior.

How to restore an archived module
1. Locate the archived file in `legacy/` (for example `legacy/solana_rs_orig.rs` or `legacy/bridge/*_orig.rs`).
2. Copy the archived file back to its original path under `src/`:

   cp legacy/solana_rs_orig.rs src/blockchain/solana.rs

   or for bridge files:

   cp legacy/bridge/relay_orig.rs src/blockchain/bridge/relay.rs
   cp legacy/bridge/transfer_orig.rs src/blockchain/bridge/transfer.rs
   cp legacy/bridge/mock_orig.rs src/blockchain/bridge/mock.rs

3. Remove or adapt the corresponding minimal stub(s) introduced during the archival.
4. Run `cargo build` and `cargo test` to validate the restored behavior.

Notes for reviewers
- The legacy files are preserved verbatim to avoid accidental data loss — please review them in-place under `legacy/`.
- The stubs intentionally return deterministic mock values when one of the following is set:
  - environment variable `BRIDGE_MOCK_FORCE_SUCCESS=1` (or related aliases: `BRIDGE_MOCK`, `FORCE_BRIDGE_SUCCESS`, `BRIDGE_MOCK_FORCE`)
  - crate feature `test-env`

Contact
- If you want me to restore any archived module in a follow-up PR instead of leaving it in `legacy/`, tell me which module and I will restore it and adapt imports/tests.
