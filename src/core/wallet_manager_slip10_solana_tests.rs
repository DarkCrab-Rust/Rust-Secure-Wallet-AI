use std::sync::Arc;

use tokio;

use crate::core::config::WalletConfig;
use crate::core::wallet_manager::WalletManager;
use crate::storage::WalletStorage;

fn zero_seed32() -> [u8; 32] {
    [0u8; 32]
}

#[tokio::test]
async fn print_solana_slip10_from_zero_seed() {
    // Build a wallet manager with in-memory storage
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );

    let cfg = WalletConfig::default();
    let wm = WalletManager::new_with_storage(&cfg, storage, None).await.expect("wm init");

    let seed = zero_seed32();

    // Derive private key and address for Solana default path m/44'/501'/0'/0'/0'
    let addr = wm.derive_address(&seed, "solana").expect("derive addr");

    println!("SOL m/44'/501'/0'/0'/0' from zero seed -> addr: {}", addr);

    // Lock in deterministic constant captured from probe
    let expected_addr = "HVEMhZbBXiAn7YnohXpLVdyFfGNvjFPpMgDGiWtu8BgZ";
    assert_eq!(addr, expected_addr);
}
