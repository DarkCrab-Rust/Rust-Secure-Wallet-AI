// src/bin/bridge_test.rs
use chrono::Utc;
use clap::{Parser, Subcommand};
use defi_hot_wallet::blockchain::bridge::{
    mock::{EthereumToBSCBridge, EthereumToSolanaBridge, SolanaToEthereumBridge},
    BridgeTransactionStatus,
};
use defi_hot_wallet::blockchain::traits::Bridge;
use defi_hot_wallet::core::{SecureWalletData, WalletInfo};
use std::str::FromStr;
use uuid::Uuid;

#[derive(Parser)]
#[clap(name = "bridge-test", about = "Test cross-chain bridge functionality")]
struct Cli {
    #[clap(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Test ETH to SOL bridge
    EthToSol {
        /// Amount to bridge
        #[clap(long, default_value = "10.0")]
        amount: String,

        /// Token symbol
        #[clap(long, default_value = "USDC")]
        token: String,
    },

    /// Test SOL to ETH bridge
    SolToEth {
        /// Amount to bridge
        #[clap(long, default_value = "10.0")]
        amount: String,

        /// Token symbol
        #[clap(long, default_value = "USDC")]
        token: String,
    },

    /// Test ETH to BSC bridge
    EthToBsc {
        /// Amount to bridge
        #[clap(long, default_value = "10.0")]
        amount: String,

        /// Token symbol
        #[clap(long, default_value = "USDT")]
        token: String,
    },
}

// Create mock SecureWalletData for tests and local runs
fn create_mock_wallet_data() -> SecureWalletData {
    SecureWalletData {
        info: WalletInfo {
            id: Uuid::from_str("12345678-1234-1234-1234-123456789012").unwrap(),
            name: "test-wallet".to_string(),
            created_at: Utc::now(),
            quantum_safe: true,
            multi_sig_threshold: 1,
            networks: vec!["eth".to_string(), "solana".to_string(), "bsc".to_string()],
        },
        encrypted_master_key: vec![1, 2, 3, 4],
        shamir_shares: vec![vec![1, 2, 3], vec![4, 5, 6], vec![7, 8, 9]],
        salt: vec![5, 6, 7, 8],
        nonce: vec![9, 10, 11, 12],
        schema_version: defi_hot_wallet::core::SecureWalletData::default_schema_version(),
        kek_id: None,
    }
}

// Helper function to monitor bridge transaction status
async fn monitor_bridge_status(bridge: &impl Bridge, tx_hash: &str) {
    tracing::info!("Monitoring bridge transaction: {}", tx_hash);

    // polling limits and timeout
    let max_checks = 10;
    let timeout = tokio::time::Duration::from_secs(20);
    let start_time = tokio::time::Instant::now();

    for i in 1..=max_checks {
        if start_time.elapsed() > timeout {
            tracing::warn!("Monitoring timed out after {} seconds", timeout.as_secs());
            break;
        }

        tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        match bridge.check_transfer_status(tx_hash).await {
            Ok(status) => {
                tracing::debug!(check = i, ?status, "Status check");
                if matches!(status, BridgeTransactionStatus::Completed) {
                    tracing::info!("Bridge transfer completed");
                }
                if let BridgeTransactionStatus::Failed(ref reason) = status {
                    tracing::warn!("Bridge transfer failed: {}", reason);
                }
            }
            Err(e) => {
                tracing::warn!("Error checking status: {}", e);
            }
        }
    }
}

// Helper function to execute a parsed bridge command
async fn execute_bridge_command(
    command: Commands,
    wallet_data: SecureWalletData,
) -> Result<(), Box<dyn std::error::Error>> {
    match command {
        Commands::EthToSol { amount, token } => {
            tracing::info!(amount = %amount, token = %token, "Testing ETH to Solana bridge");

            let bridge = EthereumToSolanaBridge::new("0xMockBridgeContract");
            let result = bridge
                .transfer_across_chains("eth", "solana", &token, &amount, &wallet_data)
                .await?;

            tracing::info!(tx = %result, "Bridge transaction initiated");
            monitor_bridge_status(&bridge, &result).await;
        }

        Commands::SolToEth { amount, token } => {
            tracing::info!(amount = %amount, token = %token, "Testing Solana to ETH bridge");

            let bridge = SolanaToEthereumBridge::new("0xMockReverseBridgeContract");
            let result = bridge
                .transfer_across_chains("solana", "eth", &token, &amount, &wallet_data)
                .await?;

            tracing::info!(tx = %result, "Bridge transaction initiated");
            monitor_bridge_status(&bridge, &result).await;
        }

        Commands::EthToBsc { amount, token } => {
            tracing::info!(amount = %amount, token = %token, "Testing ETH to BSC bridge");

            let bridge = EthereumToBSCBridge::new("0xMockEthBscBridge");
            let result =
                bridge.transfer_across_chains("eth", "bsc", &token, &amount, &wallet_data).await?;

            tracing::info!(tx = %result, "Bridge transaction initiated");
            monitor_bridge_status(&bridge, &result).await;
        }
    }
    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // initialize pretty logging for the small test binary
    tracing_subscriber::fmt::init();

    tracing::info!("Starting bridge test application");

    let cli = Cli::parse();
    let wallet_data = create_mock_wallet_data();

    execute_bridge_command(cli.command, wallet_data).await
}

#[cfg(test)]
mod tests {
    use super::*;
    use clap::CommandFactory; // For Cli::command().debug_assert()

    // Helper function to run a bridge test command programmatically
    async fn run_bridge_test(
        from_chain: &str,
        to_chain: &str,
        amount: &str,
        token: &str,
    ) -> Result<(), Box<dyn std::error::Error>> {
        // Initialize tracing for tests if not already done by tokio::test
        let _ = tracing_subscriber::fmt::try_init(); // Use try_init to avoid re-initializing

        let args = match (from_chain, to_chain) {
            ("eth", "solana") => {
                vec!["bridge-test", "eth-to-sol", "--amount", amount, "--token", token]
            }
            ("solana", "eth") => {
                vec!["bridge-test", "sol-to-eth", "--amount", amount, "--token", token]
            }
            ("eth", "bsc") => {
                vec!["bridge-test", "eth-to-bsc", "--amount", amount, "--token", token]
            }
            _ => {
                return Err(format!("Unsupported chain pair: {} to {}", from_chain, to_chain).into())
            }
        };

        let cli = Cli::try_parse_from(args)?;
        let wallet_data = create_mock_wallet_data(); // Mock wallet data for tests
        execute_bridge_command(cli.command, wallet_data).await
    }

    #[test]
    fn verify_cli() {
        Cli::command().debug_assert();
    }

    #[tokio::test]
    async fn test_bridge_execution() {
        // Allow bridge mocks for this test run and force success
        std::env::set_var("ALLOW_BRIDGE_MOCKS", "1");
        std::env::set_var("BRIDGE_MOCK_FORCE_SUCCESS", "1");
        let result = run_bridge_test("eth", "solana", "10.0", "USDC").await;
        assert!(result.is_ok());
        std::env::remove_var("BRIDGE_MOCK_FORCE_SUCCESS");
        std::env::remove_var("ALLOW_BRIDGE_MOCKS");
    }

    #[tokio::test]
    async fn test_bridge_invalid_chains() {
        let result = run_bridge_test("invalid", "solana", "10.0", "USDC").await;
        assert!(result.is_err());
        if let Err(e) = result {
            assert!(e.to_string().contains("Unsupported chain pair"));
        }
    }

    #[tokio::test]
    async fn test_bridge_zero_value() {
        std::env::set_var("ALLOW_BRIDGE_MOCKS", "1");
        std::env::set_var("BRIDGE_MOCK_FORCE_SUCCESS", "1");
        let result = run_bridge_test("eth", "solana", "0.0", "USDC").await;
        assert!(result.is_ok());
        std::env::remove_var("BRIDGE_MOCK_FORCE_SUCCESS");
        std::env::remove_var("ALLOW_BRIDGE_MOCKS");
    }

    #[tokio::test]
    async fn test_cli_parse_eth_to_sol() {
        let args = ["bridge-test", "eth-to-sol", "--amount", "5.0", "--token", "ETH"];
        let cli = Cli::try_parse_from(args).unwrap();
        match cli.command {
            Commands::EthToSol { amount, token } => {
                assert_eq!(amount, "5.0");
                assert_eq!(token, "ETH");
            }
            _ => panic!("Expected EthToSol command"),
        }
    }

    #[tokio::test]
    async fn test_cli_parse_sol_to_eth_defaults() {
        let args = ["bridge-test", "sol-to-eth"];
        let cli = Cli::try_parse_from(args).unwrap();
        match cli.command {
            Commands::SolToEth { amount, token } => {
                assert_eq!(amount, "10.0"); // Default value
                assert_eq!(token, "USDC"); // Default value
            }
            _ => panic!("Expected SolToEth command"),
        }
    }

    #[tokio::test]
    async fn test_cli_invalid_subcommand() {
        let args = ["bridge-test", "unknown-command"];
        let result = Cli::try_parse_from(args);
        assert!(result.is_err());
    }

    #[tokio::test]
    async fn test_cli_missing_amount_for_eth_to_sol() {
        // amount has a default, so this should not fail parsing
        let args = ["bridge-test", "eth-to-sol"];
        let result = Cli::try_parse_from(args);
        assert!(result.is_ok());
    }
}
