mod util;

use async_trait::async_trait;
use defi_hot_wallet::blockchain::traits::BlockchainClient;
use defi_hot_wallet::core::config::WalletConfig;
use defi_hot_wallet::core::errors::WalletError;
use defi_hot_wallet::core::WalletManager;
use std::sync::Arc;

struct MockClient {
    chain_nonce: u64,
}

#[async_trait]
impl BlockchainClient for MockClient {
    fn clone_box(&self) -> Box<dyn BlockchainClient> {
        Box::new(MockClient { chain_nonce: self.chain_nonce })
    }

    async fn get_balance(&self, _address: &str) -> Result<String, WalletError> {
        Ok("0".to_string())
    }

    async fn send_transaction(
        &self,
        _private_key: &defi_hot_wallet::core::domain::PrivateKey,
        _to_address: &str,
        _amount: &str,
    ) -> Result<String, WalletError> {
        // Return a mock tx hash immediately
        Ok("0xmocktxhash".to_string())
    }

    async fn get_transaction_status(
        &self,
        _tx_hash: &str,
    ) -> Result<defi_hot_wallet::blockchain::traits::TransactionStatus, WalletError> {
        Err(WalletError::Other("not implemented".to_string()))
    }

    async fn estimate_fee(&self, _to_address: &str, _amount: &str) -> Result<String, WalletError> {
        Ok("0".to_string())
    }

    async fn get_nonce(&self, _address: &str) -> Result<u64, WalletError> {
        Ok(self.chain_nonce)
    }

    async fn get_block_number(&self) -> Result<u64, WalletError> {
        Ok(0)
    }

    fn validate_address(&self, _address: &str) -> anyhow::Result<bool> {
        Ok(true)
    }

    fn get_network_name(&self) -> &str {
        "mock"
    }
    fn get_native_token(&self) -> &str {
        "MOCK"
    }
}

#[tokio::test]
async fn concurrent_send_advances_nonce_by_count() {
    // Enable deterministic test env (WALLET_ENC_KEY, TEST_SKIP_DECRYPT, ALLOW_BRIDGE_MOCKS)
    util::set_test_env();

    // Prepare WalletManager with in-memory storage
    let storage = Arc::new(
        defi_hot_wallet::storage::WalletStorage::new_with_url("sqlite::memory:")
            .await
            .expect("storage init"),
    );
    let cfg = WalletConfig::default();
    let mut wm = WalletManager::new_with_storage(&cfg, storage, None).await.expect("wm init");

    // Inject mock client with chain nonce 100
    let mut clients = std::collections::HashMap::new();
    clients.insert(
        "eth".to_string(),
        Box::new(MockClient { chain_nonce: 100 }) as Box<dyn BlockchainClient>,
    );
    wm.blockchain_clients = Arc::new(clients);

    // Inject a deterministic test master key so derived addresses are known
    let test_master = vec![0x77u8; 32];
    let secret_master = defi_hot_wallet::security::secret::vec_to_secret(test_master.clone());
    defi_hot_wallet::core::wallet_manager::set_test_master_key_default(secret_master.clone());

    // Create a wallet to send from
    wm.create_wallet("concurrent_send_test", true).await.expect("create wallet");

    // Derive the from_address from the injected test master key
    let from_address =
        WalletManager::derive_address(&wm, &secret_master, "eth").expect("derive address");

    let concurrency = 8usize;
    let mut handles: Vec<tokio::task::JoinHandle<String>> = Vec::new();

    // Share WalletManager across tasks
    let wm = Arc::new(wm);

    for _ in 0..concurrency {
        let wm_c = Arc::clone(&wm);
        let from = from_address.clone();
        handles.push(tokio::spawn(async move {
            // Simulate send reservation by calling get_next_nonce
            let n = wm_c.get_next_nonce(&from, "eth").await.expect("get nonce");
            // Simulate successful send by marking nonce used
            wm_c.mark_nonce_used(&from, "eth", n).await.expect("mark used");
            n.to_string()
        }));
    }

    // Wait for all sends
    for h in handles {
        let _ = h.await.expect("task join");
    }

    // Next nonce should be initial + concurrency for the from_address
    let next_nonce = wm.get_next_nonce(&from_address, "eth").await.expect("get next nonce");
    assert_eq!(next_nonce, 100 + concurrency as u64);
}
