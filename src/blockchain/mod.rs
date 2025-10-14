pub mod audit;
pub mod bridge;
pub mod ethereum;
pub mod solana;
pub mod traits; // Added minimal stub for audit module

pub use bridge::{BridgeTransaction, BridgeTransactionStatus};
pub use traits::{BlockchainClient, Bridge};
