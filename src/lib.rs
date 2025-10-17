// src/lib.rs

pub mod api;
pub mod blockchain;
pub mod cli;
pub mod core;
pub mod crypto;
pub mod security;
pub mod shamir;
pub mod storage;
pub mod tools;
// 公共模块导出，确保 tests 中 `defi_hot_wallet::network`, `::ops`, `::mvp` 可见
pub mod mvp;
pub mod network;
pub mod ops;
// Add this export so tests can use `defi_hot_wallet::audit::...`
pub mod audit;
pub mod service;
// Add i18n export for tests
pub mod i18n;

// Conditionally compile the test environment setup. Include when running `cargo test`
// or when the explicit `test-env` feature is enabled.
#[cfg(any(test, feature = "test-env"))]
mod test_env; // This will run the ctor when the feature is enabled or during tests.
