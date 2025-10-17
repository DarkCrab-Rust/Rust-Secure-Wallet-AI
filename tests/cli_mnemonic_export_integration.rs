use std::fs;
use std::process::Command;
use tempfile::tempdir;

#[test]
fn test_cli_encrypted_mnemonic_export_roundtrip() {
    // Create a temp dir for export
    let dir = tempdir().expect("tempdir");
    let out_path = dir.path().join("mnemonic.enc");

    // 32-byte test key
    let key_bytes = [0x22u8; 32];
    let key_hex = hex::encode(key_bytes);

    // Run wallet-cli generate-mnemonic with MNEMONIC_EXPORT_KEY and MNEMONIC_EXPORT_PATH
    let output = Command::new("cargo")
        .args(["run", "--bin", "wallet-cli", "--", "generate-mnemonic"])
        .env("MNEMONIC_EXPORT_KEY", key_hex)
        .env("MNEMONIC_EXPORT_PATH", out_path.to_str().unwrap())
        .output()
        .expect("failed to run wallet-cli");

    assert!(
        output.status.success(),
        "wallet-cli failed: {}",
        String::from_utf8_lossy(&output.stderr)
    );

    // Read the file and decrypt using the library helper
    let blob = fs::read(&out_path).expect("read export file");

    // Call into library helper by executing a small Rust test harness via `cargo run` is heavy; instead
    // we'll use the crate test helper function by compiling the library tests. For simplicity, re-derive
    // the decryption logic here (must match the library format: 12-byte nonce || ciphertext).

    use aes_gcm::{aead::Aead, Aes256Gcm, KeyInit};

    // Construct cipher from raw key bytes (returns Result)
    let cipher = Aes256Gcm::new_from_slice(&key_bytes).expect("invalid key");

    assert!(blob.len() > 12, "export blob too small");
    let (nonce_bytes, ciphertext) = blob.split_at(12);
    let nonce = {
        // Transitive deps currently expose a deprecated `from_slice` API. Allow it in tests
        // until dependencies are upgraded across the workspace.
        #[allow(deprecated)]
        aes_gcm::aead::Nonce::<Aes256Gcm>::from_slice(nonce_bytes)
    };

    use aes_gcm::aead::Payload;
    let aad = out_path.to_str().unwrap().as_bytes();
    let plaintext = cipher.decrypt(nonce, Payload { msg: ciphertext, aad }).expect("decrypt");
    let mnemonic = String::from_utf8(plaintext).expect("utf8");

    // Expect the test mnemonic (same as in cli code)
    let expected = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    assert_eq!(mnemonic, expected);

    // Cleanup
    dir.close().ok();
}
