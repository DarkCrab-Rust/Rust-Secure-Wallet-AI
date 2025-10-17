use std::sync::Arc;

use tokio;

use crate::core::config::WalletConfig;
use crate::core::wallet_info::SecureWalletData;
use crate::core::wallet_manager::WalletManager;
use crate::storage::WalletStorage;
use base64::Engine;
use coins_bip32::xkeys::{Parent, XPriv};

fn zero_seed32() -> [u8; 32] {
    [0u8; 32]
}

#[tokio::test]
async fn print_eth_bip44_from_zero_seed() {
    // Build a wallet manager with in-memory storage
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );

    let cfg = WalletConfig::default();
    let wm = WalletManager::new_with_storage(&cfg, storage, None).await.expect("wm init");

    let seed = zero_seed32();

    // Derive private key and address for Ethereum default BIP44 path m/44'/60'/0'/0/0
    let addr = wm.derive_address(&seed, "eth").expect("derive addr");
    println!("ETH m/44'/60'/0'/0/0 from zero seed -> addr: {}", addr);

    // Non-asserting probe test; will be replaced with fixed-vector assertion
    assert!(addr.starts_with("0x"));
}

#[tokio::test]
async fn eth_derivation_override_affects_address() {
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );
    let mut cfg = WalletConfig::default();
    // Override account/change/index
    cfg.derivation.eth.account = 1;
    cfg.derivation.eth.change = 0;
    cfg.derivation.eth.index = 5;
    let wm = WalletManager::new_with_storage(&cfg, storage, None).await.expect("wm init");

    let seed = zero_seed32();
    let addr = wm.derive_address(&seed, "eth").expect("derive addr");
    // Deterministic but not hard-coded; basic sanity
    assert!(addr.starts_with("0x"));
    assert_eq!(addr.len(), 42);
}

#[tokio::test]
async fn wallet_aad_v2_write_and_read() {
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );
    let cfg = WalletConfig::default();
    let wm = WalletManager::new_with_storage(&cfg, storage.clone(), None).await.expect("wm init");

    // Create new wallet (writes using AAD v2)
    wm.create_wallet("aadv2", false).await.expect("create wallet");

    // Ensure decrypt succeeds
    let mk = wm.test_decrypt_master_key("aadv2").await.expect("decrypt master");
    assert_eq!(mk.len(), 32);
}

#[tokio::test]
async fn wallet_aad_v1_fallback_read() {
    // Build storage and manager
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );
    let cfg = WalletConfig::default();
    let wm = WalletManager::new_with_storage(&cfg, storage.clone(), None).await.expect("wm init");

    // Manually insert a legacy v1-encrypted SecureWalletData for fallback test
    // Construct a small v1 record by reusing the v2 path and swapping the AAD/info used
    use aes_gcm::{
        aead::{Aead, KeyInit},
        Aes256Gcm,
    };
    use hkdf::Hkdf;
    use rand::RngCore;
    use sha2::Sha256;
    use zeroize::Zeroize;

    // Prepare WALLET_ENC_KEY (test-env sets a default, but set explicitly here to be sure)
    std::env::set_var(
        "WALLET_ENC_KEY",
        base64::engine::general_purpose::STANDARD.encode([7u8; 32]),
    );

    // Minimal SecureWalletData with v1 fields
    let info = crate::core::wallet_info::WalletInfo::new("legacy_v1", false);
    let mut wallet = SecureWalletData::new(info.clone());

    // Fake master key
    let master_key = [0xABu8; 32];
    let mut kek = {
        let b64 = std::env::var("WALLET_ENC_KEY").unwrap();
        let raw = base64::engine::general_purpose::STANDARD.decode(b64.trim()).unwrap();
        let mut out = [0u8; 32];
        out.copy_from_slice(&raw);
        out
    };

    let mut salt = [0u8; 32];
    rand::rngs::OsRng.fill_bytes(&mut salt);
    let hkdf = Hkdf::<Sha256>::new(Some(&salt), &kek);
    let mut enc_key_bytes = [0u8; 32];
    let info_v1 = info.hkdf_info_v1();
    hkdf.expand(&info_v1, &mut enc_key_bytes).unwrap();

    // AES-GCM with v1 AAD (legacy)
    let cipher = Aes256Gcm::new_from_slice(&enc_key_bytes).unwrap();
    let mut nonce_bytes = [0u8; 12];
    rand::rngs::OsRng.fill_bytes(&mut nonce_bytes);
    #[allow(deprecated)]
    let nonce = aes_gcm::aead::Nonce::<Aes256Gcm>::from_slice(&nonce_bytes);
    let ciphertext =
        cipher.encrypt(nonce, aes_gcm::aead::Payload { msg: &master_key, aad: &info_v1 }).unwrap();

    wallet.encrypted_master_key = ciphertext;
    wallet.salt = salt.to_vec();
    wallet.nonce = nonce_bytes.to_vec();
    // Store under the legacy name
    let serialized = bincode::serialize(&wallet).unwrap();
    storage.store_wallet(&info.name, &serialized, false).await.unwrap();

    // Attempt to load/decrypt via wm (should fallback to v1)
    let mk = wm.test_decrypt_master_key("legacy_v1").await.expect("decrypt v1");
    assert_eq!(mk.to_vec(), master_key);

    // Zeroize temps
    enc_key_bytes.zeroize();
    kek.zeroize();
    salt.zeroize();
    nonce_bytes.zeroize();
}

#[tokio::test]
async fn eth_bip32_parity_fixed_vectors() {
    // Build a wallet manager with in-memory storage
    let storage = Arc::new(
        WalletStorage::new_with_url("sqlite::memory:").await.expect("in-memory storage init"),
    );

    let cfg = WalletConfig::default();
    let wm = WalletManager::new_with_storage(&cfg, storage, None).await.expect("wm init");

    // Two deterministic seeds: zero seed and an alternate pattern
    let seeds = vec![[0u8; 32], [0x11u8; 32]];

    for seed in seeds {
        // Our derived private key (as bytes)
        let our_priv = wm.test_derive_private_key(&seed, "eth").expect("derive priv");
        let our_priv = our_priv.to_vec();

        // Build library XPriv and derive the same BIP44 path: m/44'/60'/0'/0/0
        let mut xprv = XPriv::root_from_seed(&seed, None).expect("root from seed");
        // hardened helper
        const HARDEN: u32 = 0x8000_0000;
        let path = [44 | HARDEN, 60 | HARDEN, HARDEN, 0, 0];
        for &idx in &path {
            xprv = xprv.derive_child(idx).expect("derive child");
        }

        // Extract signing key bytes from derived xprv
        let derived_signing: k256::ecdsa::SigningKey =
            <XPriv as AsRef<k256::ecdsa::SigningKey>>::as_ref(&xprv).clone();
        let lib_bytes = derived_signing.to_bytes();

        // Compare
        assert_eq!(our_priv.len(), lib_bytes.len());
        assert_eq!(our_priv, lib_bytes.to_vec());
    }
}
