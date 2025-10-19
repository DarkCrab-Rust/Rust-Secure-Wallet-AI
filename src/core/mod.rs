pub mod abi;
pub mod config;
pub mod domain;
pub mod errors;
pub mod key_management;
pub mod memory_protection;
pub mod validation;
pub mod wallet;
pub mod wallet_info;
pub mod wallet_manager;

// 閲嶆柊瀵煎嚭鍏抽敭缁撴瀯
pub use wallet_info::{SecureWalletData, WalletInfo};
pub use wallet_manager::WalletManager;

// Test-only helper modules for HD derivation probes/vectors
#[cfg(test)]
mod wallet_manager_bip44_tests;
#[cfg(test)]
mod wallet_manager_slip10_solana_tests;
