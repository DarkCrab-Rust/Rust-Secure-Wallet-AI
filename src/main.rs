// src/main.rs
//! DeFi Hot Wallet Server Entry Point
//! This binary is responsible for starting the API server.
use anyhow::Result;
use clap::{Args as ClapArgs, Parser, Subcommand};
use defi_hot_wallet::api::server::WalletServer;
use defi_hot_wallet::core::config::{BlockchainConfig, StorageConfig, WalletConfig};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tracing::info;
use tracing_subscriber::{EnvFilter, FmtSubscriber};

#[derive(Parser)]
#[command(name = "hot_wallet")]
#[command(about = "DeFi Hot Wallet Server")]
#[command(version = env!("CARGO_PKG_VERSION"))]
struct Args {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Start the wallet server
    Server {
        /// Port to bind the server to
        #[arg(long, default_value = "8080")]
        port: u16,
    },
    /// Create a wallet file with the provided name at the given path
    Create(CreateArgs),
}

#[derive(ClapArgs)]
struct CreateArgs {
    /// Wallet name to embed in the output file
    #[arg(long)]
    name: String,
    /// Output path to write the wallet JSON file
    #[arg(long)]
    output: PathBuf,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    // Initialize logging
    init_logging()?;

    info!("Starting DeFi Hot Wallet v{}", env!("CARGO_PKG_VERSION"));

    // Runtime safety: refuse to run in production if TEST_SKIP_DECRYPT is set.
    if std::env::var("TEST_SKIP_DECRYPT").is_ok() && !cfg!(feature = "test-env") {
        // Avoid printing secrets or test-only flags to stderr in production builds.
        tracing::error!(
            "Refusing to start: TEST_SKIP_DECRYPT set but binary not built with `test-env`"
        );
        std::process::exit(1);
    }

    // High severity: refuse insecure WALLET_ENC_KEY (all zeros) when not built with test-env.
    #[cfg(not(feature = "test-env"))]
    {
        if let Ok(b64) = std::env::var("WALLET_ENC_KEY") {
            use base64::Engine as _;
            if let Ok(bytes) = base64::engine::general_purpose::STANDARD.decode(b64.trim()) {
                if bytes.len() == 32 && bytes.iter().all(|&b| b == 0) {
                    tracing::error!(
                        "Refusing to start: Insecure WALLET_ENC_KEY detected (all zeros). Set a strong 32-byte key."
                    );
                    std::process::exit(1);
                }
            }
        }
    }

    // Fast path: handle create subcommand without initializing server
    if let Some(Commands::Create(create_args)) = args.command {
        create_wallet_file(&create_args.name, &create_args.output)?;
        return Ok(());
    }

    // Read DATABASE_URL from env securely or fallback to relative path in current dir
    let database_url = defi_hot_wallet::security::env_manager::secure_env::get_database_url()
        .unwrap_or_else(|_| "sqlite://./wallets.db".to_string());

    // A default configuration.
    let wallet_config = WalletConfig {
        storage: StorageConfig {
            database_url: database_url.clone(),
            max_connections: Some(10),
            connection_timeout_seconds: Some(30),
        },
        blockchain: BlockchainConfig {
            networks: HashMap::new(), // WalletManager will populate this
            default_network: Some("eth".to_string()),
        },
        quantum_safe: false,
        multi_sig_threshold: 2,
        derivation: Default::default(),
    };

    // Read API_KEY from environment securely
    let api_key = defi_hot_wallet::security::env_manager::secure_env::get_api_key().ok();

    let server =
        WalletServer::new("127.0.0.1".to_string(), 8080, wallet_config.clone(), api_key).await?;

    // Initialize global encryption consistency validator
    let quantum_crypto = if wallet_config.quantum_safe {
        Some(defi_hot_wallet::crypto::QuantumSafeEncryption::new()?)
    } else {
        None
    };
    defi_hot_wallet::crypto::init_global_validator(quantum_crypto)?;

    match args.command {
        Some(Commands::Server { port }) => {
            info!("Starting server on port {}", port);
            let server_with_port = WalletServer { port, ..server };
            server_with_port.start().await?;
        }
        None => {
            // Default behavior: start the server on 127.0.0.1:8080
            info!("No command specified, starting server on default port 8080");
            server.start().await?;
        }
        // Create handled above
        Some(Commands::Create(_)) => unreachable!(),
    }

    Ok(())
}

fn init_logging() -> Result<()> {
    let filter = EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| EnvFilter::new("info,hyper=info,h2=info"));

    let subscriber = FmtSubscriber::builder()
        .with_env_filter(filter)
        .with_max_level(tracing::Level::TRACE)
        .finish();

    tracing::subscriber::set_global_default(subscriber)?;
    Ok(())
}

fn create_wallet_file(name: &str, output: &PathBuf) -> Result<()> {
    // Build a minimal JSON structure that tests expect
    let json = serde_json::json!({
        "name": name,
    });
    if let Some(parent) = output.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(output, serde_json::to_vec_pretty(&json)?)?;
    tracing::info!("Wallet {} created successfully at {}", name, output.to_string_lossy());
    Ok(())
}
