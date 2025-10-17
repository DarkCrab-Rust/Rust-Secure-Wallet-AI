use anyhow::Result;
#[allow(unused_imports)]
use rand::RngCore;
use secp256k1::{ecdsa::Signature, Message, PublicKey, Secp256k1};
use std::collections::HashMap;
use tracing::{info, warn};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AmountPrecision {
    /// Human-entered/raw (may include decimals or not normalized)
    Raw,
    /// Minimal-unit integer (e.g., wei/lamports)
    Minimal,
}

#[derive(Debug, Clone)]
pub struct MultiSigConfig {
    pub threshold: u8,
    pub total_signers: u8,
    pub signers: Vec<PublicKey>, // Public keys for signature verification
}

#[derive(Debug, Clone)]
pub struct MultiSigTransaction {
    pub id: String,
    pub to_address: String,
    pub amount: String,
    pub network: String,
    signatures: HashMap<String, (PublicKey, Signature)>, // signer_id -> (pubkey, signature)
    pub threshold: u8,
    pub created_at: chrono::DateTime<chrono::Utc>,
    // Optional policy binding to prevent signer-set substitution
    pub allowed_signers: Option<Vec<PublicKey>>, // canonical sorted list
    pub nonce: Option<u64>,
    pub chain_id: Option<u64>,
    pub amount_precision: AmountPrecision,
}

impl MultiSigTransaction {
    /// Return the number of collected signatures for this transaction.
    pub fn signature_count(&self) -> usize {
        self.signatures.len()
    }

    /// Return a vector of hex-encoded signatures paired with signer pubkey hex.
    /// This avoids exposing raw owned byte buffers and provides a safe view for external callers.
    pub fn signatures_hex(&self) -> Vec<(String, String)> {
        self.signatures
            .iter()
            .map(|(signer_id, (_pk, sig))| {
                // Serialize signature to compact (64 bytes) then hex
                let compact = sig.serialize_compact();
                (signer_id.clone(), hex::encode(compact))
            })
            .collect()
    }
}

pub struct MultiSignature {
    pending_transactions: HashMap<String, MultiSigTransaction>,
}

impl MultiSignature {
    pub fn new() -> Self {
        info!("馃攼 Initializing Multi-Signature manager");
        Self { pending_transactions: HashMap::new() }
    }

    /// Set required replay-protection context for a pending transaction.
    /// Both nonce and chain_id must be provided together and are immutable once set.
    pub fn set_nonce_and_chain_id(&mut self, tx_id: &str, nonce: u64, chain_id: u64) -> Result<()> {
        let tx = self
            .pending_transactions
            .get_mut(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;
        if tx.nonce.is_some() || tx.chain_id.is_some() {
            return Err(anyhow::anyhow!(
                "nonce/chain_id already set for transaction {}; immutable",
                tx_id
            ));
        }
        tx.nonce = Some(nonce);
        tx.chain_id = Some(chain_id);
        Ok(())
    }

    /// Mark the amount as minimal-unit precision for signing. This flag is required before signing.
    /// Optionally, callers should normalize `amount` to minimal units (e.g., wei/lamports) beforehand.
    pub fn set_amount_precision_minimal(&mut self, tx_id: &str) -> Result<()> {
        let tx = self
            .pending_transactions
            .get_mut(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;
        tx.amount_precision = AmountPrecision::Minimal;
        Ok(())
    }

    pub fn create_multisig_config(
        threshold: u8,
        signers: Vec<PublicKey>,
    ) -> Result<MultiSigConfig> {
        if threshold == 0 || threshold > (signers.len() as u8) {
            return Err(anyhow::anyhow!(
                "Invalid threshold: {} (must be 1-{}))",
                threshold,
                signers.len()
            ));
        }

        if signers.is_empty() {
            return Err(anyhow::anyhow!("At least one signer is required"));
        }

        info!("鉁?Created {}-of-{} multi-signature configuration", threshold, signers.len());

        Ok(MultiSigConfig { threshold, total_signers: signers.len() as u8, signers })
    }

    /// Backward compatible proposal API without explicit signer set; use with care.
    pub fn propose_transaction(
        &mut self,
        id: String,
        to_address: String,
        amount: String,
        network: String,
        threshold: u8,
    ) -> Result<()> {
        self.propose_with_config(id, to_address, amount, network, threshold, None)
    }

    /// Preferred proposal API that binds signer set and threshold into the canonical message.
    pub fn propose_with_config(
        &mut self,
        id: String,
        to_address: String,
        amount: String,
        network: String,
        threshold: u8,
        allowed_signers: Option<Vec<PublicKey>>,
    ) -> Result<()> {
        if self.pending_transactions.contains_key(&id) {
            return Err(anyhow::anyhow!("Transaction with ID {} already exists", id));
        }

        // Normalize allowed_signers deterministically and deduplicate if provided
        let allowed_sorted = allowed_signers.map(|mut v| {
            v.sort_by(|a, b| format!("{:x}", a).cmp(&format!("{:x}", b)));
            v.dedup_by(|a, b| format!("{:x}", a) == format!("{:x}", b));
            v
        });

        // If a signer set is bound, enforce threshold does not exceed unique signers
        if let Some(ref signers) = allowed_sorted {
            if threshold == 0 || (threshold as usize) > signers.len() {
                return Err(anyhow::anyhow!(
                    "Invalid threshold: {} (must be 1-{} for bound signer set)",
                    threshold,
                    signers.len()
                ));
            }
        } else if threshold == 0 {
            return Err(anyhow::anyhow!("Invalid threshold: 0"));
        }

        let transaction = MultiSigTransaction {
            id: id.clone(),
            to_address,
            amount,
            network,
            signatures: HashMap::new(),
            threshold,
            created_at: chrono::Utc::now(),
            allowed_signers: allowed_sorted,
            nonce: None,
            chain_id: None,
            amount_precision: AmountPrecision::Raw,
        };

        self.pending_transactions.insert(id.clone(), transaction);

        info!("📝 Proposed multi-sig transaction: {}", id);
        Ok(())
    }

    #[allow(clippy::too_many_arguments)]
    fn canon_message(
        id: &str,
        to: &str,
        amount: &str,
        network: &str,
        threshold: u8,
        allowed_signers: Option<&[PublicKey]>,
        nonce: Option<u64>,
        chain_id: Option<u64>,
        amount_precision: AmountPrecision,
    ) -> Result<Message> {
        // Deterministic structured encoding: domain tag + version + length-prefixed fields.
        // Layout:
        //   TAG(= "DEFISAFE-MSIG") || VER(= 0x04) ||
        //   len(id)||id || len(to)||to || len(amount)||amount || prec(1) || len(net)||net || th(1) ||
        //   signers_count(2) || each signer(33 or 65 bytes serialized) ||
        //   nonce_present(1)||[nonce(8)] || chain_present(1)||[chain_id(8)]
        use sha2::{Digest, Sha256};

        let mut buf = Vec::with_capacity(256);
        // Domain tag and version
        buf.extend_from_slice(b"DEFISAFE-MSIG");
        buf.push(0x04);

        // helper to encode length-prefixed bytes (u32 BE)
        fn put_lp(dst: &mut Vec<u8>, bytes: &[u8]) {
            let len = bytes.len() as u32;
            dst.extend_from_slice(&len.to_be_bytes());
            dst.extend_from_slice(bytes);
        }

        put_lp(&mut buf, id.as_bytes());
        put_lp(&mut buf, to.as_bytes());
        put_lp(&mut buf, amount.as_bytes());
        // precision
        buf.push(match amount_precision {
            AmountPrecision::Raw => 0u8,
            AmountPrecision::Minimal => 1u8,
        });
        put_lp(&mut buf, network.as_bytes());
        buf.push(threshold);

        // Signers: canonical order by compressed serialized bytes
        if let Some(signers) = allowed_signers {
            let mut ser: Vec<[u8; 33]> = signers
                .iter()
                .map(|pk| pk.serialize())
                .map(|v| {
                    let mut a = [0u8; 33];
                    a.copy_from_slice(&v);
                    a
                })
                .collect();
            ser.sort();
            let count = ser.len() as u16;
            buf.extend_from_slice(&count.to_be_bytes());
            for s in ser {
                buf.extend_from_slice(&s);
            }
        } else {
            buf.extend_from_slice(&0u16.to_be_bytes());
        }

        // Optional fields presence flags + values
        match nonce {
            Some(n) => {
                buf.push(1);
                buf.extend_from_slice(&n.to_be_bytes());
            }
            None => buf.push(0),
        }
        match chain_id {
            Some(c) => {
                buf.push(1);
                buf.extend_from_slice(&c.to_be_bytes());
            }
            None => buf.push(0),
        }

        let digest = Sha256::digest(&buf);
        secp256k1::Message::from_slice(&digest).map_err(|_| anyhow::anyhow!("Invalid message hash"))
    }

    /// Build the canonical message that signers must sign for a pending transaction.
    pub fn message_to_sign(&self, tx_id: &str) -> Result<Message> {
        let tx = self
            .pending_transactions
            .get(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;
        Self::canon_message(
            &tx.id,
            &tx.to_address,
            &tx.amount,
            &tx.network,
            tx.threshold,
            tx.allowed_signers.as_deref(),
            tx.nonce,
            tx.chain_id,
            tx.amount_precision,
        )
    }

    pub fn sign_transaction(
        &mut self,
        tx_id: &str,
        signer_pubkey: &PublicKey,
        signature: &Signature,
    ) -> Result<bool> {
        // Fetch the pending transaction to build canonical message
        let transaction = self
            .pending_transactions
            .get(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;

        // Enforce replay protection and precision context before accepting signatures
        if transaction.nonce.is_none() || transaction.chain_id.is_none() {
            return Err(anyhow::anyhow!(
                "nonce and chain_id must be set before signing (use set_nonce_and_chain_id)"
            ));
        }
        if transaction.amount_precision != AmountPrecision::Minimal {
            return Err(anyhow::anyhow!(
                "amount_precision must be Minimal before signing (use set_amount_precision_minimal)"
            ));
        }
        let message = Self::canon_message(
            &transaction.id,
            &transaction.to_address,
            &transaction.amount,
            &transaction.network,
            transaction.threshold,
            transaction.allowed_signers.as_deref(),
            transaction.nonce,
            transaction.chain_id,
            transaction.amount_precision,
        )?;

        // Verify signature
        let secp = Secp256k1::verification_only();
        if secp.verify_ecdsa(&message, signature, signer_pubkey).is_err() {
            return Err(anyhow::anyhow!("Invalid signature from signer"));
        }

        // Enforce signer membership if policy bound
        if let Some(allowed) = &transaction.allowed_signers {
            let signer_hex = format!("{:x}", signer_pubkey);
            let allowed_hex: Vec<String> = allowed.iter().map(|pk| format!("{:x}", pk)).collect();
            if !allowed_hex.iter().any(|s| s == &signer_hex) {
                return Err(anyhow::anyhow!("Signer not in allowed signer set"));
            }
        }

        let transaction = self
            .pending_transactions
            .get_mut(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;

        // Store signature with signer identifier (using pubkey as string for now);
        // reject duplicate signature attempts from the same signer to avoid ambiguity
        let signer_id = format!("{:x}", signer_pubkey);
        if transaction.signatures.contains_key(&signer_id) {
            return Err(anyhow::anyhow!("Duplicate signature from the same signer"));
        }
        transaction.signatures.insert(signer_id, (*signer_pubkey, *signature));

        let signatures_count = transaction.signature_count() as u8;
        let is_complete = signatures_count >= transaction.threshold;

        if is_complete {
            info!(
                "鉁?Multi-sig transaction {} is ready for execution ({}/{} signatures)",
                tx_id, signatures_count, transaction.threshold
            );
        } else {
            info!(
                "馃摑 Multi-sig transaction {} signed ({}/{} signatures)",
                tx_id, signatures_count, transaction.threshold
            );
        }

        Ok(is_complete)
    }

    pub fn execute_transaction(&mut self, tx_id: &str) -> Result<MultiSigTransaction> {
        let transaction = self
            .pending_transactions
            .remove(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;

        let signatures_count = transaction.signature_count() as u8;
        if signatures_count < transaction.threshold {
            // Put it back since it's not ready
            let threshold = transaction.threshold;
            self.pending_transactions.insert(tx_id.to_string(), transaction);
            return Err(anyhow::anyhow!(
                "Insufficient signatures: {}/{}",
                signatures_count,
                threshold
            ));
        }

        info!("馃殌 Executing multi-sig transaction: {}", tx_id);
        Ok(transaction)
    }

    pub fn get_transaction(&self, tx_id: &str) -> Option<&MultiSigTransaction> {
        self.pending_transactions.get(tx_id)
    }

    pub fn list_pending_transactions(&self) -> Vec<&MultiSigTransaction> {
        self.pending_transactions.values().collect()
    }

    pub fn cancel_transaction(&mut self, tx_id: &str) -> Result<()> {
        self.pending_transactions
            .remove(tx_id)
            .ok_or_else(|| anyhow::anyhow!("Transaction not found: {}", tx_id))?;

        warn!("鉂?Cancelled multi-sig transaction: {}", tx_id);
        Ok(())
    }
}

impl Default for MultiSignature {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use secp256k1::{KeyPair, Secp256k1, SecretKey};

    #[test]
    fn test_multisig_config() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut key_bytes1 = [0u8; 32];
        let mut key_bytes2 = [0u8; 32];
        let mut key_bytes3 = [0u8; 32];
        rng.fill_bytes(&mut key_bytes1);
        rng.fill_bytes(&mut key_bytes2);
        rng.fill_bytes(&mut key_bytes3);
        let sk1 = SecretKey::from_slice(&key_bytes1).unwrap();
        let sk2 = SecretKey::from_slice(&key_bytes2).unwrap();
        let sk3 = SecretKey::from_slice(&key_bytes3).unwrap();
        let keypair1 = KeyPair::from_secret_key(&secp, &sk1);
        let keypair2 = KeyPair::from_secret_key(&secp, &sk2);
        let keypair3 = KeyPair::from_secret_key(&secp, &sk3);

        let signers = vec![keypair1.public_key(), keypair2.public_key(), keypair3.public_key()];

        let config = MultiSignature::create_multisig_config(2, signers).unwrap();
        assert_eq!(config.threshold, 2);
        assert_eq!(config.total_signers, 3);
        assert_eq!(config.signers.len(), 3);
    }

    #[test]
    fn test_multisig_transaction_flow() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut key_bytes1 = [0u8; 32];
        let mut key_bytes2 = [0u8; 32];
        rng.fill_bytes(&mut key_bytes1);
        rng.fill_bytes(&mut key_bytes2);
        let sk1 = SecretKey::from_slice(&key_bytes1).unwrap();
        let sk2 = SecretKey::from_slice(&key_bytes2).unwrap();
        let keypair1 = KeyPair::from_secret_key(&secp, &sk1);
        let keypair2 = KeyPair::from_secret_key(&secp, &sk2);

        let mut multisig = MultiSignature::new();

        // Propose transaction
        multisig
            .propose_transaction(
                "tx1".to_string(),
                "0x1234".to_string(),
                "1.0".to_string(),
                "eth".to_string(),
                2,
            )
            .unwrap();

        // Set required context before signing
        multisig.set_nonce_and_chain_id("tx1", 0, 1).unwrap();
        multisig.set_amount_precision_minimal("tx1").unwrap();

        // Create message and signatures using canonical encoding
        let message = multisig.message_to_sign("tx1").unwrap();

        let sig1 = secp.sign_ecdsa(&message, &keypair1.secret_key());
        let complete = multisig.sign_transaction("tx1", &keypair1.public_key(), &sig1).unwrap();
        assert!(!complete);

        // Second signature (should complete)
        let sig2 = secp.sign_ecdsa(&message, &keypair2.secret_key());
        let complete = multisig.sign_transaction("tx1", &keypair2.public_key(), &sig2).unwrap();
        assert!(complete);

        // Execute transaction
    let tx = multisig.execute_transaction("tx1").unwrap();
    assert_eq!(tx.id, "tx1");
    assert_eq!(tx.signature_count(), 2);
    }

    #[test]
    fn test_insufficient_signatures() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut key_bytes1 = [0u8; 32];
        rng.fill_bytes(&mut key_bytes1);
        let sk1 = SecretKey::from_slice(&key_bytes1).unwrap();
        let keypair1 = KeyPair::from_secret_key(&secp, &sk1);

        let mut multisig = MultiSignature::new();

        multisig
            .propose_transaction(
                "tx1".to_string(),
                "0x1234".to_string(),
                "1.0".to_string(),
                "eth".to_string(),
                2,
            )
            .unwrap();

        // Set required context before signing
        multisig.set_nonce_and_chain_id("tx1", 7, 1).unwrap();
        multisig.set_amount_precision_minimal("tx1").unwrap();

        // Only one signature
        let message = multisig.message_to_sign("tx1").unwrap();
        let sig1 = secp.sign_ecdsa(&message, &keypair1.secret_key());
        multisig.sign_transaction("tx1", &keypair1.public_key(), &sig1).unwrap();

        // Try to execute with insufficient signatures
        let result = multisig.execute_transaction("tx1");
        assert!(result.is_err());
    }

    #[test]
    fn test_invalid_signature() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut key_bytes1 = [0u8; 32];
        rng.fill_bytes(&mut key_bytes1);
        let sk1 = SecretKey::from_slice(&key_bytes1).unwrap();
        let keypair1 = KeyPair::from_secret_key(&secp, &sk1);

        let mut multisig = MultiSignature::new();

        multisig
            .propose_transaction(
                "tx1".to_string(),
                "0x1234".to_string(),
                "1.0".to_string(),
                "eth".to_string(),
                1,
            )
            .unwrap();

        // Set required context before signing
        multisig.set_nonce_and_chain_id("tx1", 1, 1).unwrap();
        multisig.set_amount_precision_minimal("tx1").unwrap();

        // Try to sign with wrong message (different amount)
        let wrong_message = MultiSignature::canon_message(
            "tx1",
            "0x1234",
            "2.0",
            "eth",
            1,
            None,
            None,
            None,
            AmountPrecision::Raw,
        )
        .unwrap();
        let invalid_sig = secp.sign_ecdsa(&wrong_message, &keypair1.secret_key());

        let result = multisig.sign_transaction("tx1", &keypair1.public_key(), &invalid_sig);
        assert!(result.is_err());
    }

    #[test]
    fn test_multisig_with_signer_set_binding() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut key_bytes1 = [0u8; 32];
        let mut key_bytes2 = [0u8; 32];
        let mut key_bytes3 = [0u8; 32];
        rng.fill_bytes(&mut key_bytes1);
        rng.fill_bytes(&mut key_bytes2);
        rng.fill_bytes(&mut key_bytes3);
        let sk1 = secp256k1::SecretKey::from_slice(&key_bytes1).unwrap();
        let sk2 = secp256k1::SecretKey::from_slice(&key_bytes2).unwrap();
        let sk3 = secp256k1::SecretKey::from_slice(&key_bytes3).unwrap();
        let kp1 = secp256k1::KeyPair::from_secret_key(&secp, &sk1);
        let kp2 = secp256k1::KeyPair::from_secret_key(&secp, &sk2);
        let kp3 = secp256k1::KeyPair::from_secret_key(&secp, &sk3);

        let mut ms = MultiSignature::new();
        ms.propose_with_config(
            "tx_bind".to_string(),
            "0xabc".to_string(),
            "1.5".to_string(),
            "eth".to_string(),
            2,
            Some(vec![kp1.public_key(), kp2.public_key()]),
        )
        .unwrap();

        // Set required context before signing
        ms.set_nonce_and_chain_id("tx_bind", 0, 1).unwrap();
        ms.set_amount_precision_minimal("tx_bind").unwrap();

        // Build the canonical message using the bound policy
        let msg = ms.message_to_sign("tx_bind").unwrap();

        let sig1 = secp.sign_ecdsa(&msg, &kp1.secret_key());
        let complete = ms.sign_transaction("tx_bind", &kp1.public_key(), &sig1).unwrap();
        assert!(!complete);

        // A signer outside the allowed set should be rejected
        let sig3 = secp.sign_ecdsa(&msg, &kp3.secret_key());
        let res = ms.sign_transaction("tx_bind", &kp3.public_key(), &sig3);
        assert!(res.is_err());

        // Second allowed signer completes
        let sig2 = secp.sign_ecdsa(&msg, &kp2.secret_key());
        let complete = ms.sign_transaction("tx_bind", &kp2.public_key(), &sig2).unwrap();
        assert!(complete);

    let tx = ms.execute_transaction("tx_bind").unwrap();
    assert_eq!(tx.signature_count(), 2);
    }

    #[test]
    fn test_canonical_message_signer_order_invariance() {
        let secp = Secp256k1::new();
        let mut rng = rand::rngs::OsRng;
        let mut kb1 = [0u8; 32];
        let mut kb2 = [0u8; 32];
        rng.fill_bytes(&mut kb1);
        rng.fill_bytes(&mut kb2);
        let sk1 = SecretKey::from_slice(&kb1).unwrap();
        let sk2 = SecretKey::from_slice(&kb2).unwrap();
        let kp1 = KeyPair::from_secret_key(&secp, &sk1);
        let kp2 = KeyPair::from_secret_key(&secp, &sk2);

        // Propose with reversed signer orders across two managers
        let mut ms_a = MultiSignature::new();
        ms_a.propose_with_config(
            "txo".to_string(),
            "0xabc".to_string(),
            "1".to_string(),
            "eth".to_string(),
            2,
            Some(vec![kp2.public_key(), kp1.public_key()]),
        )
        .unwrap();
        let msg_a = ms_a.message_to_sign("txo").unwrap();

        let mut ms_b = MultiSignature::new();
        ms_b.propose_with_config(
            "txo".to_string(),
            "0xabc".to_string(),
            "1".to_string(),
            "eth".to_string(),
            2,
            Some(vec![kp1.public_key(), kp2.public_key()]),
        )
        .unwrap();
        let msg_b = ms_b.message_to_sign("txo").unwrap();

        // Canonical encoding should be identical regardless of input order
        assert_eq!(msg_a.as_ref(), msg_b.as_ref());
    }

    #[test]
    fn test_canonical_message_optional_fields_flags() {
        // Directly exercise canon_message to vary optional fields
        let msg_none = MultiSignature::canon_message(
            "id",
            "to",
            "10",
            "eth",
            2,
            None,
            None,
            None,
            AmountPrecision::Raw,
        )
        .unwrap();

        let msg_nonce = MultiSignature::canon_message(
            "id",
            "to",
            "10",
            "eth",
            2,
            None,
            Some(42),
            None,
            AmountPrecision::Raw,
        )
        .unwrap();

        let msg_chain = MultiSignature::canon_message(
            "id",
            "to",
            "10",
            "eth",
            2,
            None,
            None,
            Some(1),
            AmountPrecision::Raw,
        )
        .unwrap();

        let msg_both = MultiSignature::canon_message(
            "id",
            "to",
            "10",
            "eth",
            2,
            None,
            Some(42),
            Some(1),
            AmountPrecision::Raw,
        )
        .unwrap();

        // With presence flags, each variant should differ when fields differ
        assert_ne!(msg_none.as_ref(), msg_nonce.as_ref());
        assert_ne!(msg_none.as_ref(), msg_chain.as_ref());
        assert_ne!(msg_nonce.as_ref(), msg_chain.as_ref());
        assert_ne!(msg_both.as_ref(), msg_none.as_ref());
    }
}
