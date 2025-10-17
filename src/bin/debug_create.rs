use defi_hot_wallet::api::server::WalletServer;
use defi_hot_wallet::core::config::{BlockchainConfig, StorageConfig, WalletConfig};
use std::collections::HashMap;

#[tokio::main]
async fn main() {
    // Mirror create_test_config from tests
    let config = WalletConfig {
        storage: StorageConfig {
            database_url: "sqlite::memory:".to_string(),
            max_connections: Some(1),
            connection_timeout_seconds: Some(30),
        },
        blockchain: BlockchainConfig {
            networks: HashMap::new(),
            default_network: Some("eth".to_string()),
        },
        quantum_safe: false,
        multi_sig_threshold: 2,
        derivation: Default::default(),
    };

    // Set same envs as new_for_test
    std::env::set_var("WALLET_ENC_KEY", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=");
    std::env::set_var("TEST_SKIP_DECRYPT", "1");
    std::env::set_var("BRIDGE_MOCK_FORCE_SUCCESS", "1");
    std::env::set_var("BRIDGE_MOCK", "1");
    std::env::set_var("ALLOW_BRIDGE_MOCKS", "1");

    let test_master_key = defi_hot_wallet::security::secret::vec_to_secret(vec![0u8; 32]);
    let server = WalletServer::new_for_test(
        "127.0.0.1".to_string(),
        0,
        config,
        Some(zeroize::Zeroizing::new("test_api_key".as_bytes().to_vec())),
        Some(test_master_key),
    )
    .await
    .expect("create server");

    // Directly call create_wallet on the manager to reproduce the error path
    let wm = server.wallet_manager.clone();
    match wm.create_wallet("debug_wallet", true).await {
        Ok(info) => println!("Created wallet: {}", info.name),
        Err(e) => println!("create_wallet failed: {}", e),
    }
}
