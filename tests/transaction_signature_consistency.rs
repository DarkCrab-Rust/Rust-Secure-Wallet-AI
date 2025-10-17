use defi_hot_wallet::crypto::multisig::MultiSignature;
use secp256k1::{Secp256k1, SecretKey};

#[test]
fn test_transaction_signature_consistency() {
    // Build a multisig manager and propose a transaction
    let mut ms = MultiSignature::new();
    let tx_id = "tx-consistency-1".to_string();
    ms.propose_transaction(
        tx_id.clone(),
        "0xdeadbeef".to_string(),
        "1000".to_string(),
        "ethereum".to_string(),
        1,
    )
    .expect("propose");

    // Set nonce/chain and amount precision so signing is allowed
    ms.set_nonce_and_chain_id(&tx_id, 1u64, 1u64).expect("set nonce/chain");
    ms.set_amount_precision_minimal(&tx_id).expect("set precision");

    // Prepare a test secret key
    let secp = Secp256k1::new();
    let sk = SecretKey::from_slice(&[0x77u8; 32]).expect("secret key");

    // Build canonical message
    let msg = ms.message_to_sign(&tx_id).expect("message");

    // Sign the message twice using the same secret key
    let sig1 = secp.sign_ecdsa(&msg, &sk);
    let sig2 = secp.sign_ecdsa(&msg, &sk);

    assert_eq!(
        sig1.serialize_compact().to_vec(),
        sig2.serialize_compact().to_vec(),
        "signatures must be deterministic for same input"
    );
}
