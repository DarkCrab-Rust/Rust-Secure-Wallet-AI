use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize)]
pub struct CreateWalletRequest {
    pub name: String,
    pub quantum_safe: bool,
}

#[derive(Serialize)]
pub struct WalletResponse {
    pub id: String,
    pub name: String,
    pub quantum_safe: bool,
}

#[derive(Clone, Debug, Deserialize)]
pub struct SendTransactionRequest {
    pub to_address: String,
    pub amount: String,
    pub network: String,
}

#[derive(Serialize)]
pub struct TransactionResponse {
    pub tx_hash: String,
    pub status: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct BridgeAssetsRequest {
    pub from_wallet: String,
    pub from_chain: String,
    pub to_chain: String,
    pub token: String,
    pub amount: String,
}

#[derive(Serialize)]
pub struct BridgeResponse {
    pub bridge_tx_id: String,
}

#[derive(Serialize)]
pub struct BridgeTransactionResponse {
    pub id: String,
    pub from_wallet: String,
    pub from_chain: String,
    pub to_chain: String,
    pub token: String,
    pub amount: String,
    pub status: String,
    pub source_tx_hash: Option<String>,
    pub destination_tx_hash: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub fee_amount: Option<String>,
    pub estimated_completion_time: Option<String>,
}

#[derive(Serialize)]
pub struct BalanceResponse {
    pub balance: String,
    pub network: String,
    pub symbol: String,
}

#[derive(Serialize)]
pub struct TransactionHistoryResponse {
    pub transactions: Vec<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct EncryptedBackupResponse {
    /// Format version for the encrypted backup object
    pub version: String,
    /// Algorithm used, e.g. AES-256-GCM
    pub alg: String,
    /// KEK identifier used to encrypt this backup (optional)
    pub kek_id: Option<String>,
    /// Base64-encoded nonce
    pub nonce: String,
    /// Base64-encoded ciphertext (encrypted seed phrase)
    pub ciphertext: String,
    /// Wallet name for reference
    pub wallet: String,
}

// Backwards-compatible alias for handler usage in tests; production handlers should
// return `EncryptedBackupResponse`. For test-env, we still allow returning plaintext
// in the `ciphertext` field with `alg = "PLAINTEXT"` to preserve deterministic tests.
pub type BackupResponse = EncryptedBackupResponse;

#[derive(Clone, Debug, Deserialize)]
pub struct RestoreWalletRequest {
    pub name: String,
    pub seed_phrase: String,
    #[serde(default)]
    pub quantum_safe: bool,
}

#[derive(Clone, Debug, Deserialize)]
pub struct MultiSigTransactionRequest {
    pub to_address: String,
    pub amount: String,
    pub network: String,
    pub signatures: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ErrorResponse {
    pub error: String,
    pub code: String,
}

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct RotateSigningKeyResponse {
    pub wallet: String,
    pub old_version: u32,
    pub new_version: u32,
}
