mod util;

use axum::extract::State;
use axum::http::StatusCode;
use axum::Json;
use serde_json::Value;
use std::sync::Arc;

use defi_hot_wallet::api::handlers::{bridge_assets, health_check, metrics_handler};
use defi_hot_wallet::api::server::WalletServer;
use defi_hot_wallet::api::types::BridgeAssetsRequest;
use defi_hot_wallet::core::config::{BlockchainConfig, StorageConfig, WalletConfig};

#[tokio::test(flavor = "current_thread")]
async fn handlers_health_and_metrics() {
    // health_check()
    let h = health_check().await;
    let body: Value = h.0;
    assert_eq!(body["status"], "ok");
    assert!(body["version"].is_string());
    assert!(body["timestamp"].is_string());

    // metrics_handler()
    let m = metrics_handler().await;
    assert!(m.contains("defi_hot_wallet_requests_total"));
}

#[tokio::test(flavor = "current_thread")]
async fn handlers_bridge_assets_branches() {
    // Ensure deterministic test env (WALLET_ENC_KEY, TEST_SKIP_DECRYPT, ALLOW_BRIDGE_MOCKS)
    util::set_test_env();
    // Set up test environment variables used by some code paths
    std::env::set_var(
        "WALLET_MASTER_KEY",
        "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    );

    // prepare a WalletServer with in-memory sqlite
    let config = WalletConfig {
        storage: StorageConfig {
            database_url: "sqlite::memory:".to_string(),
            ..Default::default()
        },
        blockchain: BlockchainConfig {
            networks: std::collections::HashMap::new(),
            default_network: Some("ethereum".to_string()),
        },
        quantum_safe: false,
        multi_sig_threshold: 1,
        derivation: Default::default(),
    };
    let server = WalletServer::new("127.0.0.1".to_string(), 8080, config, None)
        .await
        .expect("wallet server init");
    let state = State(Arc::new(server));

    // empty parameters -> Invalid parameters (rate limiting happens after basic validation)
    let req = BridgeAssetsRequest {
        from_wallet: "".to_string(),
        from_chain: "eth".to_string(),
        to_chain: "solana".to_string(),
        token: "USDC".to_string(),
        amount: "1.0".to_string(),
    };
    let res = bridge_assets(state.clone(), Json(req)).await;
    assert!(res.is_err());
    let (code, body) = res.err().unwrap();
    assert_eq!(code, StatusCode::BAD_REQUEST);
    assert_eq!(body.0.error, "Missing required parameters");

    // invalid amount (non-numeric)
    let req2 = BridgeAssetsRequest {
        from_wallet: "w".to_string(),
        from_chain: "eth".to_string(),
        to_chain: "solana".to_string(),
        token: "USDC".to_string(),
        amount: "abc".to_string(),
    };
    let res2 = bridge_assets(state.clone(), Json(req2)).await;
    assert!(res2.is_err());
    let (code2, body2) = res2.err().unwrap();
    assert_eq!(code2, StatusCode::BAD_REQUEST);
    assert_eq!(body2.0.error, "Invalid amount: Invalid amount format");

    // unsupported chain
    let req3 = BridgeAssetsRequest {
        from_wallet: "w".to_string(),
        from_chain: "invalid_chain".to_string(),
        to_chain: "solana".to_string(),
        token: "USDC".to_string(),
        amount: "1.0".to_string(),
    };
    let res3 = bridge_assets(state.clone(), Json(req3)).await;
    assert!(res3.is_err());
    let (code3, body3) = res3.err().unwrap();
    assert_eq!(code3, StatusCode::BAD_REQUEST);
    assert_eq!(body3.0.error, "Unsupported chain");

    // success path: create wallet first then call with fresh server (avoid rate limiting)
    std::env::set_var("BRIDGE_MOCK_FORCE_SUCCESS", "1");
    let config2 = WalletConfig {
        storage: StorageConfig {
            database_url: "sqlite::memory:".to_string(),
            ..Default::default()
        },
        blockchain: BlockchainConfig {
            networks: std::collections::HashMap::new(),
            default_network: Some("ethereum".to_string()),
        },
        quantum_safe: false,
        multi_sig_threshold: 1,
        derivation: Default::default(),
    };
    let server2 = WalletServer::new("127.0.0.1".to_string(), 8080, config2, None)
        .await
        .expect("wallet server init");
    let state2 = State(Arc::new(server2));
    let wm_arc = state2.0.clone();
    wm_arc.wallet_manager.create_wallet("test_w", false).await.expect("create wallet");

    let req4 = BridgeAssetsRequest {
        from_wallet: "test_w".to_string(),
        from_chain: "eth".to_string(),
        to_chain: "solana".to_string(),
        token: "USDC".to_string(),
        amount: "1.0".to_string(),
    };

    let res4 = bridge_assets(state2, Json(req4)).await;
    assert!(res4.is_ok());
    let br = res4.ok().unwrap().0;
    let txid = br.bridge_tx_id.as_str();
    assert!(txid == "mock_bridge_tx_hash" || txid.starts_with("0x_simulated"));
}
