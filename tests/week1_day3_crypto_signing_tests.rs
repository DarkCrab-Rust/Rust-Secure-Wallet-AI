//! Week 1 Day 3: 加密签名和验证测试
//! 目标: 测试加密模块的签名和验证功能
//! 
//! 测试范围:
//! - ECDSA签名（secp256k1）
//! - 签名验证
//! - 签名确定性
//! - 公钥恢复
//! - Low-S 规范化
//! - 多签名基础功能

use defi_hot_wallet::crypto::multisig::MultiSignature;
use defi_hot_wallet::crypto::signature_utils::{ensure_low_s, normalize_v};
use secp256k1::{Secp256k1, SecretKey, Message, PublicKey};
use sha2::{Sha256, Digest};

// ============================================================================
// 辅助函数
// ============================================================================

/// 创建测试用的密钥
fn create_test_secret_key(seed: u8) -> SecretKey {
    let sk_bytes: Vec<u8> = std::iter::repeat_n(seed, 32).collect();
    SecretKey::from_slice(&sk_bytes).expect("Failed to create secret key")
}

/// 创建测试消息
fn create_test_message(content: &str) -> Message {
    let mut hasher = Sha256::new();
    hasher.update(content.as_bytes());
    let hash = hasher.finalize();
    Message::from_slice(&hash).expect("Failed to create message")
}

// ============================================================================
// ECDSA签名基础测试
// ============================================================================

#[test]
fn test_ecdsa_sign_and_verify() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    let public_key = PublicKey::from_secret_key(&secp, &secret_key);
    
    let message = create_test_message("test transaction");
    
    // 签名
    let signature = secp.sign_ecdsa(&message, &secret_key);
    
    // 验证
    let verify_result = secp.verify_ecdsa(&message, &signature, &public_key);
    
    assert!(verify_result.is_ok(), "签名验证应该成功");
}

#[test]
fn test_ecdsa_sign_wrong_key_fails_verification() {
    let secp = Secp256k1::new();
    
    let secret_key1 = create_test_secret_key(0x42);
    let secret_key2 = create_test_secret_key(0x43);
    
    let public_key1 = PublicKey::from_secret_key(&secp, &secret_key1);
    
    let message = create_test_message("test transaction");
    
    // 用key2签名
    let signature = secp.sign_ecdsa(&message, &secret_key2);
    
    // 用key1的公钥验证（应该失败）
    let verify_result = secp.verify_ecdsa(&message, &signature, &public_key1);
    
    assert!(verify_result.is_err(), "错误的公钥验证应该失败");
}

#[test]
fn test_ecdsa_sign_wrong_message_fails_verification() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    let public_key = PublicKey::from_secret_key(&secp, &secret_key);
    
    let message1 = create_test_message("message 1");
    let message2 = create_test_message("message 2");
    
    // 签名message1
    let signature = secp.sign_ecdsa(&message1, &secret_key);
    
    // 用message2验证（应该失败）
    let verify_result = secp.verify_ecdsa(&message2, &signature, &public_key);
    
    assert!(verify_result.is_err(), "错误的消息验证应该失败");
}

// ============================================================================
// 签名确定性测试
// ============================================================================

#[test]
fn test_signature_deterministic() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    let message = create_test_message("deterministic test");
    
    // 多次签名同一消息
    let sig1 = secp.sign_ecdsa(&message, &secret_key);
    let sig2 = secp.sign_ecdsa(&message, &secret_key);
    let sig3 = secp.sign_ecdsa(&message, &secret_key);
    
    // 所有签名应该完全相同
    assert_eq!(
        sig1.serialize_compact(),
        sig2.serialize_compact(),
        "签名应该是确定性的"
    );
    assert_eq!(
        sig1.serialize_compact(),
        sig3.serialize_compact(),
        "签名应该是确定性的"
    );
}

#[test]
fn test_different_messages_different_signatures() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    
    let message1 = create_test_message("message 1");
    let message2 = create_test_message("message 2");
    
    let sig1 = secp.sign_ecdsa(&message1, &secret_key);
    let sig2 = secp.sign_ecdsa(&message2, &secret_key);
    
    assert_ne!(
        sig1.serialize_compact(),
        sig2.serialize_compact(),
        "不同消息应该产生不同签名"
    );
}

// ============================================================================
// 可恢复签名测试
// ============================================================================

#[test]
fn test_recoverable_signature() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    let message = create_test_message("recoverable test");
    
    // 创建可恢复签名
    let rec_sig = secp.sign_ecdsa_recoverable(&message, &secret_key);
    
    // 从签名恢复公钥
    let recovered_pubkey = secp.recover_ecdsa(&message, &rec_sig)
        .expect("应该能恢复公钥");
    
    // 验证恢复的公钥与原始公钥一致
    let original_pubkey = PublicKey::from_secret_key(&secp, &secret_key);
    
    assert_eq!(
        recovered_pubkey,
        original_pubkey,
        "恢复的公钥应该与原始公钥一致"
    );
}

#[test]
fn test_recoverable_signature_serialize() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x42);
    let message = create_test_message("serialize test");
    
    let rec_sig = secp.sign_ecdsa_recoverable(&message, &secret_key);
    
    // 序列化为 (recovery_id, compact_bytes)
    let (rec_id, compact) = rec_sig.serialize_compact();
    
    // 验证格式
    assert_eq!(compact.len(), 64, "compact签名应该是64字节");
    assert!(rec_id.to_i32() >= 0 && rec_id.to_i32() < 4, "recovery ID应该在0-3之间");
}

// ============================================================================
// Low-S 规范化测试
// ============================================================================

#[test]
fn test_ensure_low_s_normalization() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x55);
    let message = create_test_message("low-s test");
    
    let signature = secp.sign_ecdsa(&message, &secret_key);
    let compact = signature.serialize_compact();
    
    let mut compact_arr = [0u8; 64];
    compact_arr.copy_from_slice(&compact);
    
    // 确保Low-S
    let normalized = ensure_low_s(&compact_arr);
    
    // 验证规范化后的签名仍然有效
    let normalized_sig = secp256k1::ecdsa::Signature::from_compact(&normalized)
        .expect("规范化后的签名应该有效");
    
    let public_key = PublicKey::from_secret_key(&secp, &secret_key);
    let verify_result = secp.verify_ecdsa(&message, &normalized_sig, &public_key);
    
    assert!(verify_result.is_ok(), "规范化后的签名应该能验证通过");
}

// ============================================================================
// V值规范化测试
// ============================================================================

#[test]
fn test_normalize_v_standard_values() {
    assert_eq!(normalize_v(27), 27, "v=27应该保持不变");
    assert_eq!(normalize_v(28), 28, "v=28应该保持不变");
}

#[test]
fn test_normalize_v_eip155_values() {
    // EIP-155: v = chain_id * 2 + 35 或 36
    // normalize_v 使用 v & 1 来提取奇偶性
    // 以太坊主网 chain_id = 1
    assert_eq!(normalize_v(37), 28, "v=37 (奇数) 应该规范化为28"); // 1*2+35, 37&1=1 → 27+1=28
    assert_eq!(normalize_v(38), 27, "v=38 (偶数) 应该规范化为27"); // 1*2+36, 38&1=0 → 27+0=27
    
    // BSC chain_id = 56
    assert_eq!(normalize_v(147), 28, "v=147 (奇数) 应该规范化为28"); // 56*2+35, 147&1=1 → 27+1=28
    assert_eq!(normalize_v(148), 27, "v=148 (偶数) 应该规范化为27"); // 56*2+36, 148&1=0 → 27+0=27
}

// ============================================================================
// 多签名基础测试
// ============================================================================

#[test]
fn test_multisig_propose_transaction() {
    let mut ms = MultiSignature::new();
    
    let result = ms.propose_transaction(
        "tx-001".to_string(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "1.0".to_string(),
        "ethereum".to_string(),
        2, // threshold
    );
    
    assert!(result.is_ok(), "提议交易应该成功");
}

#[test]
fn test_multisig_duplicate_transaction_id() {
    let mut ms = MultiSignature::new();
    
    let tx_id = "duplicate-tx".to_string();
    
    // 第一次提议
    ms.propose_transaction(
        tx_id.clone(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "1.0".to_string(),
        "ethereum".to_string(),
        2,
    ).unwrap();
    
    // 第二次提议相同ID（应该失败）
    let result = ms.propose_transaction(
        tx_id,
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "2.0".to_string(),
        "ethereum".to_string(),
        2,
    );
    
    assert!(result.is_err(), "重复的交易ID应该失败");
}

#[test]
fn test_multisig_sign_transaction() {
    let mut ms = MultiSignature::new();
    let tx_id = "tx-sign-test".to_string();
    
    // 提议交易
    ms.propose_transaction(
        tx_id.clone(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "1.0".to_string(),
        "ethereum".to_string(),
        2,
    ).unwrap();
    
    // 设置必要参数
    ms.set_nonce_and_chain_id(&tx_id, 1, 1).unwrap();
    ms.set_amount_precision_minimal(&tx_id).unwrap();
    
    // 创建签名者
    let secp = Secp256k1::new();
    let sk = create_test_secret_key(0x77);
    let pubkey = PublicKey::from_secret_key(&secp, &sk);
    
    // 获取待签名消息
    let message = ms.message_to_sign(&tx_id).expect("应该能获取待签名消息");
    
    // 签名
    let signature = secp.sign_ecdsa(&message, &sk);
    
    // 使用正确的API添加签名
    let result = ms.sign_transaction(&tx_id, &pubkey, &signature);
    
    assert!(result.is_ok(), "签名交易应该成功");
}

#[test]
fn test_multisig_threshold_execution() {
    let mut ms = MultiSignature::new();
    let tx_id = "tx-threshold-test".to_string();
    
    // 提议交易，需要2个签名
    ms.propose_transaction(
        tx_id.clone(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "1.0".to_string(),
        "ethereum".to_string(),
        2, // threshold = 2
    ).unwrap();
    
    ms.set_nonce_and_chain_id(&tx_id, 1, 1).unwrap();
    ms.set_amount_precision_minimal(&tx_id).unwrap();
    
    let secp = Secp256k1::new();
    let message = ms.message_to_sign(&tx_id).unwrap();
    
    // 第一个签名
    let sk1 = create_test_secret_key(0x11);
    let pubkey1 = PublicKey::from_secret_key(&secp, &sk1);
    let sig1 = secp.sign_ecdsa(&message, &sk1);
    let signed1 = ms.sign_transaction(&tx_id, &pubkey1, &sig1).unwrap();
    
    // 检查第一次签名结果（false表示还未达到threshold）
    assert_eq!(signed1, false, "1个签名不应该达到threshold");
    
    // 第二个签名
    let sk2 = create_test_secret_key(0x22);
    let pubkey2 = PublicKey::from_secret_key(&secp, &sk2);
    let sig2 = secp.sign_ecdsa(&message, &sk2);
    let signed2 = ms.sign_transaction(&tx_id, &pubkey2, &sig2).unwrap();
    
    // 第二次签名应该达到threshold
    assert_eq!(signed2, true, "2个签名应该达到threshold=2");
}

// ============================================================================
// 签名确定性测试
// ============================================================================

#[test]
fn test_signature_deterministic_same_input() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x99);
    let message = create_test_message("deterministic message");
    
    // 多次签名
    let signatures: Vec<_> = (0..10)
        .map(|_| secp.sign_ecdsa(&message, &secret_key))
        .collect();
    
    // 所有签名应该相同
    let first_sig = signatures[0].serialize_compact();
    for sig in &signatures[1..] {
        assert_eq!(
            sig.serialize_compact(),
            first_sig,
            "所有签名应该完全相同"
        );
    }
}

#[test]
fn test_signature_different_keys_different_sigs() {
    let secp = Secp256k1::new();
    let message = create_test_message("same message");
    
    let sk1 = create_test_secret_key(0x11);
    let sk2 = create_test_secret_key(0x22);
    let sk3 = create_test_secret_key(0x33);
    
    let sig1 = secp.sign_ecdsa(&message, &sk1);
    let sig2 = secp.sign_ecdsa(&message, &sk2);
    let sig3 = secp.sign_ecdsa(&message, &sk3);
    
    // 不同密钥应该产生不同签名
    assert_ne!(sig1.serialize_compact(), sig2.serialize_compact());
    assert_ne!(sig1.serialize_compact(), sig3.serialize_compact());
    assert_ne!(sig2.serialize_compact(), sig3.serialize_compact());
}

// ============================================================================
// 公钥恢复测试
// ============================================================================

#[test]
fn test_recover_pubkey_from_signature() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x66);
    let original_pubkey = PublicKey::from_secret_key(&secp, &secret_key);
    
    let message = create_test_message("recovery test");
    
    // 创建可恢复签名
    let rec_sig = secp.sign_ecdsa_recoverable(&message, &secret_key);
    
    // 恢复公钥
    let recovered_pubkey = secp.recover_ecdsa(&message, &rec_sig)
        .expect("应该能恢复公钥");
    
    assert_eq!(
        recovered_pubkey,
        original_pubkey,
        "恢复的公钥应该与原始公钥一致"
    );
}

#[test]
fn test_recover_pubkey_wrong_message_fails() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x77);
    let original_pubkey = PublicKey::from_secret_key(&secp, &secret_key);
    
    let message1 = create_test_message("original message");
    let message2 = create_test_message("wrong message");
    
    // 用message1签名
    let rec_sig = secp.sign_ecdsa_recoverable(&message1, &secret_key);
    
    // 用message2恢复（会得到错误的公钥）
    let recovered_pubkey = secp.recover_ecdsa(&message2, &rec_sig)
        .expect("恢复操作本身应该成功");
    
    assert_ne!(
        recovered_pubkey,
        original_pubkey,
        "错误的消息应该恢复出不同的公钥"
    );
}

// ============================================================================
// 签名格式转换测试
// ============================================================================

#[test]
fn test_signature_compact_der_conversion() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x88);
    let message = create_test_message("format conversion");
    
    let signature = secp.sign_ecdsa(&message, &secret_key);
    
    // Compact格式 (64字节: r||s)
    let compact = signature.serialize_compact();
    assert_eq!(compact.len(), 64, "compact格式应该是64字节");
    
    // DER格式
    let der = signature.serialize_der();
    assert!(der.len() >= 70 && der.len() <= 73, "DER格式通常是70-73字节");
}

// ============================================================================
// 边界条件测试
// ============================================================================

#[test]
fn test_sign_empty_message() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0x99);
    
    // 空消息哈希
    let empty_hash = Sha256::digest(b"");
    let message = Message::from_slice(&empty_hash)
        .expect("应该能从空哈希创建消息");
    
    // 签名应该成功
    let signature = secp.sign_ecdsa(&message, &secret_key);
    
    // 验证应该成功
    let pubkey = PublicKey::from_secret_key(&secp, &secret_key);
    let verify_result = secp.verify_ecdsa(&message, &signature, &pubkey);
    
    assert!(verify_result.is_ok(), "空消息的签名验证应该成功");
}

#[test]
fn test_sign_max_message() {
    let secp = Secp256k1::new();
    let secret_key = create_test_secret_key(0xAA);
    
    // 最大消息（全是0xFF）
    let max_bytes = vec![0xFFu8; 1024];
    let max_hash = Sha256::digest(&max_bytes);
    let message = Message::from_slice(&max_hash)
        .expect("应该能创建消息");
    
    // 签名应该成功
    let signature = secp.sign_ecdsa(&message, &secret_key);
    
    // 验证应该成功
    let pubkey = PublicKey::from_secret_key(&secp, &secret_key);
    let verify_result = secp.verify_ecdsa(&message, &signature, &pubkey);
    
    assert!(verify_result.is_ok(), "大消息的签名验证应该成功");
}

// ============================================================================
// 多签名完整流程测试
// ============================================================================

#[test]
fn test_multisig_complete_workflow() {
    let mut ms = MultiSignature::new();
    let tx_id = "workflow-tx".to_string();
    
    // 1. 提议交易
    ms.propose_transaction(
        tx_id.clone(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "10.0".to_string(),
        "ethereum".to_string(),
        2,
    ).unwrap();
    
    // 2. 设置参数
    ms.set_nonce_and_chain_id(&tx_id, 1, 1).unwrap();
    ms.set_amount_precision_minimal(&tx_id).unwrap();
    
    // 3. 获取待签名消息
    let message = ms.message_to_sign(&tx_id).unwrap();
    
    let secp = Secp256k1::new();
    
    // 4. 两个签名者签名
    let sk1 = create_test_secret_key(0x11);
    let pubkey1 = PublicKey::from_secret_key(&secp, &sk1);
    let sig1 = secp.sign_ecdsa(&message, &sk1);
    let signed1 = ms.sign_transaction(&tx_id, &pubkey1, &sig1).unwrap();
    assert_eq!(signed1, false, "第1个签名不应该达到threshold");
    
    let sk2 = create_test_secret_key(0x22);
    let pubkey2 = PublicKey::from_secret_key(&secp, &sk2);
    let sig2 = secp.sign_ecdsa(&message, &sk2);
    let signed2 = ms.sign_transaction(&tx_id, &pubkey2, &sig2).unwrap();
    
    // 5. 第2个签名应该达到threshold
    assert_eq!(signed2, true, "第2个签名应该达到threshold=2");
}

#[test]
fn test_multisig_insufficient_signatures() {
    let mut ms = MultiSignature::new();
    let tx_id = "insufficient-tx".to_string();
    
    ms.propose_transaction(
        tx_id.clone(),
        "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        "1.0".to_string(),
        "ethereum".to_string(),
        3, // 需要3个签名
    ).unwrap();
    
    ms.set_nonce_and_chain_id(&tx_id, 1, 1).unwrap();
    ms.set_amount_precision_minimal(&tx_id).unwrap();
    
    let secp = Secp256k1::new();
    let message = ms.message_to_sign(&tx_id).unwrap();
    
    // 只添加2个签名
    let mut last_result = false;
    for i in 0..2 {
        let sk = create_test_secret_key(0x11 + i * 0x11);
        let pubkey = PublicKey::from_secret_key(&secp, &sk);
        let sig = secp.sign_ecdsa(&message, &sk);
        last_result = ms.sign_transaction(&tx_id, &pubkey, &sig).unwrap();
    }
    
    // 2个签名不应该达到threshold=3
    assert_eq!(last_result, false, "2个签名不应该达到threshold=3");
}

// ============================================================================
// 并发签名测试
// ============================================================================

#[test]
fn test_concurrent_signing_operations() {
    use std::sync::Arc;
    use std::thread;
    
    let secp = Arc::new(Secp256k1::new());
    let secret_key = Arc::new(create_test_secret_key(0xCC));
    
    let handles: Vec<_> = (0..10)
        .map(|i| {
            let secp_clone = secp.clone();
            let sk_clone = secret_key.clone();
            
            thread::spawn(move || {
                let message = create_test_message(&format!("concurrent message {}", i));
                secp_clone.sign_ecdsa(&message, &sk_clone)
            })
        })
        .collect();
    
    // 等待所有线程完成
    let signatures: Vec<_> = handles.into_iter()
        .map(|h| h.join().unwrap())
        .collect();
    
    // 验证所有签名都成功生成
    assert_eq!(signatures.len(), 10, "应该生成10个签名");
    
    // 验证每个签名都是64字节
    for sig in &signatures {
        assert_eq!(sig.serialize_compact().len(), 64);
    }
}

