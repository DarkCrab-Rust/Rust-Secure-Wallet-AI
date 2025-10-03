use defi_hot_wallet::core::config::{BlockchainConfig, StorageConfig, WalletConfig};
use defi_hot_wallet::core::WalletManager;
use std::collections::HashMap;
use tokio;

/// 鍒涘缓娴嬭瘯閰嶇疆锛屼娇鐢ㄥ唴瀛樻暟鎹簱
fn create_test_config() -> WalletConfig {
    WalletConfig {
        storage: StorageConfig {
            database_url: "sqlite::memory:".to_string(),
            max_connections: Some(1),
            connection_timeout_seconds: Some(5),
        },
        blockchain: BlockchainConfig {
            networks: HashMap::new(),
            default_network: Some("eth".to_string()),
        },
        quantum_safe: false,
        multi_sig_threshold: 2,
    }
}

#[tokio::test]
async fn test_wallet_creation_and_bridge_integration() {
    // Create a test configuration
    let config = create_test_config();

    // Initialize WalletManager
    let wallet_manager = WalletManager::new(&config).await.unwrap();

    // Test wallet creation
    let wallet_info = wallet_manager.create_wallet("test_wallet", false).await.unwrap();
    assert_eq!(wallet_info.name, "test_wallet");

    // Test listing wallets
    let wallets = wallet_manager.list_wallets().await.unwrap();
    assert!(wallets.iter().any(|w| w.name == "test_wallet"));

    // Test bridge fee calculation
    let (fee, _) = wallet_manager.calculate_bridge_fee("eth", "solana", "USDC", "100.0").unwrap();
    assert!(!fee.is_empty());

    // Clean up
    wallet_manager.delete_wallet("test_wallet").await.unwrap();
}

#[tokio::test]
async fn test_balance_and_transaction_integration() {
    // Note: This test requires actual blockchain connections or mocks
    // For now, it's a placeholder
    let config = create_test_config();
    let wallet_manager = WalletManager::new(&config).await.unwrap();

    // Create wallet
    let _wallet_info = wallet_manager.create_wallet("balance_test", false).await.unwrap();

    // Test balance (may fail without real network)
    // let balance = wallet_manager.get_balance("balance_test", "eth").await;
    // assert!(balance.is_ok()); // Uncomment when networks are available

    // Clean up
    wallet_manager.delete_wallet("balance_test").await.unwrap();
}
