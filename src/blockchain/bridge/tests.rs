// filepath: src/blockchain/bridge/tests.rs
use super::mock::{EthereumToSolanaBridge, SolanaToEthereumBridge};
use super::transfer::transfer_assets;
use super::relay::relay_transaction;
use crate::blockchain::traits::Bridge;
use super::relay::{bridge_mocks_allowed, bridge_mocks_requested_truthy};
use std::env;

#[tokio::test]
async fn test_mock_ethereum_to_solana_bridge() {
    let bridge = EthereumToSolanaBridge::new("0x...EthSolBridge...");
    let tx_hash = bridge.transfer("0xFrom", "SolTo", "1.0").await.unwrap();
    assert_eq!(tx_hash, "mock_eth_to_sol_tx_hash");

    let status = bridge.get_status("tx123").await.unwrap();
    assert_eq!(status, "completed");
}

#[tokio::test]
async fn test_mock_solana_to_ethereum_bridge() {
    let bridge = SolanaToEthereumBridge::new("0x...SolEthBridge...");
    let tx_hash = bridge.transfer("SolFrom", "0xTo", "1.0").await.unwrap();
    assert_eq!(tx_hash, "mock_sol_to_eth_tx_hash");

    let status = bridge.get_status("tx456").await.unwrap();
    assert_eq!(status, "completed");
}

#[tokio::test]
async fn test_transfer_assets_via_interface() {
    let bridge = EthereumToSolanaBridge::new("0x...EthSolBridge...");
    let tx_hash = transfer_assets(&bridge, "0xFrom", "SolTo", "1.0").await.unwrap();
    assert_eq!(tx_hash, "mock_eth_to_sol_tx_hash");
}

#[tokio::test]
async fn test_relay_transaction_via_interface() {
    let bridge = SolanaToEthereumBridge::new("0x...SolEthBridge...");
    let status = relay_transaction(&bridge, "tx789").await.unwrap();
    assert_eq!(status, "completed");
}

#[test]
fn test_bridge_mock_gating_envs() {
    // Save and clear relevant envs
    let keys = [
        "ALLOW_BRIDGE_MOCKS",
        "BRIDGE_MOCK_FORCE_SUCCESS",
        "BRIDGE_MOCK",
        "FORCE_BRIDGE_SUCCESS",
        "BRIDGE_MOCK_FORCE",
    ];
    let saved: Vec<(String, Option<String>)> = keys
        .iter()
        .map(|k| (k.to_string(), env::var(k).ok()))
        .collect();
    for k in &keys {
        env::remove_var(k);
    }

    // When nothing is set, requested = false, allowed = (false unless test-env feature set)
    assert_eq!(bridge_mocks_requested_truthy(), false);
    if !cfg!(feature = "test-env") {
        assert_eq!(bridge_mocks_allowed(), false);
    }

    // Request mocks but do not allow -> requested true, allowed false
    env::set_var("BRIDGE_MOCK", "1");
    assert_eq!(bridge_mocks_requested_truthy(), true);
    if !cfg!(feature = "test-env") {
        assert_eq!(bridge_mocks_allowed(), false);
    }

    // Allow mocks explicitly -> allowed true
    env::set_var("ALLOW_BRIDGE_MOCKS", "1");
    assert_eq!(bridge_mocks_allowed(), true);

    // Cleanup: restore envs
    for (k, v) in saved {
        match v {
            Some(val) => env::set_var(k, val),
            None => env::remove_var(k),
        }
    }
}