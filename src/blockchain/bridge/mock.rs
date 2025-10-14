// Lightweight mock re-export shim kept so legacy callers that import
// `blockchain::bridge::mock::{...}` still compile.
pub use crate::blockchain::bridge::{
    EthereumToBSCBridge, EthereumToSolanaBridge, PolygonToEthereumBridge, SolanaToEthereumBridge,
};
