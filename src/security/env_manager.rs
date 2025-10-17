use anyhow::{anyhow, Result};
use std::collections::HashMap;
use std::env;
use std::sync::{Arc, Mutex};
use tracing::{error, info, warn};
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

/// Secure environment variable manager for handling sensitive configuration
/// Provides access controls, memory safety, and audit logging for sensitive operations
#[derive(Debug)]
pub struct SecureEnvManager {
    /// Allowed environment variables that can be accessed
    allowed_vars: HashMap<String, EnvVarConfig>,
    /// Cache for decrypted sensitive values (with automatic cleanup)
    secure_cache: Mutex<HashMap<String, SecureValue>>,
    /// Audit log for sensitive operations
    audit_log: Mutex<Vec<AuditEntry>>,
}

#[derive(Debug, Clone)]
struct EnvVarConfig {
    /// Whether this variable contains sensitive data
    sensitive: bool,
    /// Required permission level to access
    permission_level: PermissionLevel,
    /// Whether to cache the value in memory
    cacheable: bool,
    /// Maximum age for cached values (in seconds)
    max_age_seconds: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PermissionLevel {
    Public,    // Can be accessed by any code
    Internal,  // Requires internal access
    Sensitive, // Requires elevated permissions
    Critical,  // Requires highest security clearance
}

#[derive(Debug)]
struct SecureValue {
    // Keep sensitive bytes wrapped in Zeroizing so cloned/moved buffers are zeroed on drop
    value: Zeroizing<Vec<u8>>,
    created_at: std::time::Instant,
    access_count: u32,
    #[allow(dead_code)]
    last_accessed: std::time::Instant,
}

#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct AuditEntry {
    timestamp: chrono::DateTime<chrono::Utc>,
    operation: String,
    variable: String,
    success: bool,
    details: String,
}

impl AuditEntry {
    /// Return a clone of the details string for callers that need to inspect
    /// audit entry contents without exposing internal fields directly.
    pub fn details(&self) -> String {
        self.details.clone()
    }
}

impl SecureEnvManager {
    /// Create a new secure environment manager with default configuration
    pub fn new() -> Self {
        let mut allowed_vars = HashMap::new();

        // Configure allowed environment variables with security levels
        allowed_vars.insert(
            "DATABASE_URL".to_string(),
            EnvVarConfig {
                sensitive: false,
                permission_level: PermissionLevel::Internal,
                cacheable: true,
                max_age_seconds: Some(3600), // 1 hour
            },
        );

        allowed_vars.insert(
            "API_KEY".to_string(),
            EnvVarConfig {
                sensitive: true,
                permission_level: PermissionLevel::Sensitive,
                cacheable: false, // Never cache API keys
                max_age_seconds: None,
            },
        );

        allowed_vars.insert(
            "WALLET_MASTER_KEY".to_string(),
            EnvVarConfig {
                sensitive: true,
                permission_level: PermissionLevel::Critical,
                cacheable: false, // Never cache master keys
                max_age_seconds: None,
            },
        );

        allowed_vars.insert(
            "WALLET_BACKUP_KEY".to_string(),
            EnvVarConfig {
                sensitive: true,
                permission_level: PermissionLevel::Critical,
                cacheable: false, // Never cache backup KEKs
                max_age_seconds: None,
            },
        );

        allowed_vars.insert(
            "WALLET_BACKUP_OPERATOR_KEY".to_string(),
            EnvVarConfig {
                sensitive: true,
                permission_level: PermissionLevel::Sensitive,
                cacheable: false, // Never cache operator keys
                max_age_seconds: None,
            },
        );

        allowed_vars.insert(
            "WALLET_ETHEREUM_RPC_URL".to_string(),
            EnvVarConfig {
                sensitive: false,
                permission_level: PermissionLevel::Public,
                cacheable: true,
                max_age_seconds: Some(1800), // 30 minutes
            },
        );

        allowed_vars.insert(
            "BRIDGE_MOCK_FORCE_SUCCESS".to_string(),
            EnvVarConfig {
                sensitive: false,
                permission_level: PermissionLevel::Internal,
                cacheable: true,
                max_age_seconds: Some(300), // 5 minutes
            },
        );

        Self {
            allowed_vars,
            secure_cache: Mutex::new(HashMap::new()),
            audit_log: Mutex::new(Vec::new()),
        }
    }

    /// Get a string value from environment with security checks
    pub fn get_string(&self, key: &str, required_permission: PermissionLevel) -> Result<String> {
        self.audit_operation("get_string", key, || {
            let config = self.get_config(key)?;

            // Check permission level
            if !self.check_permission(&config.permission_level, &required_permission) {
                return Err(anyhow!("Insufficient permissions to access {}", key));
            }

            // For sensitive variables, check if we have a cached value
            if config.sensitive && config.cacheable {
                if let Some(secure_value) = self.secure_cache.lock().unwrap().get(key) {
                    if self.is_cache_valid(secure_value, &config) {
                        // Clone the Zeroizing<Vec<u8>> content into a temporary Vec for decoding
                        let tmp = secure_value.value.clone();
                        let value = String::from_utf8(tmp.to_vec())
                            .map_err(|e| anyhow!("Invalid UTF-8 in cached value: {}", e))?;
                        return Ok(value);
                    }
                }
            }

            // Read from environment
            match env::var(key) {
                Ok(value) => {
                    // For sensitive values that can be cached, store securely

                    if config.sensitive && config.cacheable {
                        let secure_value = SecureValue {
                            value: Zeroizing::new(value.as_bytes().to_vec()),
                            created_at: std::time::Instant::now(),
                            access_count: 1,
                            last_accessed: std::time::Instant::now(),
                        };
                        self.secure_cache.lock().unwrap().insert(key.to_string(), secure_value);
                    }

                    Ok(value)
                }
                Err(env::VarError::NotPresent) => {
                    Err(anyhow!("Environment variable {} not set", key))
                }
                Err(e) => Err(anyhow!("Error reading environment variable {}: {}", key, e)),
            }
        })
    }

    /// Get a byte array value from environment (for binary keys)
    /// Returns a Zeroizing<Vec<u8>> to ensure memory is zeroed on drop
    pub fn get_bytes(
        &self,
        key: &str,
        required_permission: PermissionLevel,
    ) -> Result<zeroize::Zeroizing<Vec<u8>>> {
        self.audit_operation("get_bytes", key, || {
            let config = self.get_config(key)?;

            // Check permission level
            if !self.check_permission(&config.permission_level, &required_permission) {
                return Err(anyhow!("Insufficient permissions to access {}", key));
            }

            // Read from environment
            let raw_value =
                env::var(key).map_err(|_| anyhow!("Environment variable {} not set", key))?;

            // Normalize: trim outer whitespace and allow optional 0x/0X prefix
            let mut hex_value = raw_value.trim().to_string();
            if hex_value.starts_with("0x") || hex_value.starts_with("0X") {
                // Safe to slice since prefix length is 2
                hex_value = hex_value[2..].to_string();
            }

            // Remove any internal whitespace to be robust against env contamination
            hex_value.retain(|c| !c.is_whitespace());

            // Ensure even number of hex digits
            if hex_value.len() % 2 != 0 {
                return Err(anyhow!("Invalid hex format for {}: odd number of hex digits", key));
            }

            // Decode hex into Vec<u8>
            let bytes = hex::decode(&hex_value)
                .map_err(|e| anyhow!("Invalid hex format for {}: {}", key, e))?;

            // Validate length for known key types (apply check to normalized hex)
            if key == "WALLET_MASTER_KEY" {
                // 64 hex chars = 32 bytes
                if hex_value.len() != 64 {
                    return Err(anyhow!(
                        "WALLET_MASTER_KEY must be exactly 64 hex characters (32 bytes)"
                    ));
                }
                if bytes.len() != 32 {
                    return Err(anyhow!(
                        "WALLET_MASTER_KEY decoded to {} bytes, expected 32",
                        bytes.len()
                    ));
                }
            }

            Ok(zeroize::Zeroizing::new(bytes))
        })
    }

    /// Securely clear a cached value
    pub fn clear_cache(&self, key: &str) -> Result<()> {
        self.audit_operation("clear_cache", key, || {
            let mut cache = self.secure_cache.lock().unwrap();
            if let Some(mut value) = cache.remove(key) {
                value.zeroize();
                info!("Cleared cached value for {}", key);
                Ok(())
            } else {
                warn!("No cached value found for {}", key);
                Ok(())
            }
        })
    }

    /// Clear all cached sensitive values
    pub fn clear_all_cache(&self) -> Result<()> {
        let mut cache = self.secure_cache.lock().unwrap();
        let keys: Vec<String> = cache.keys().cloned().collect();

        for key in keys {
            if let Some(mut value) = cache.remove(&key) {
                value.zeroize();
            }
        }

        info!("Cleared all cached sensitive values");
        Ok(())
    }

    /// Get audit log entries
    pub fn get_audit_log(&self) -> Vec<AuditEntry> {
        self.audit_log.lock().unwrap().clone()
    }

    /// Retrieve the last audit entry, if any. This returns a clone so tests
    /// and callers don't need access to internal private fields.
    pub fn get_last_audit_entry(&self) -> Option<AuditEntry> {
        self.audit_log.lock().unwrap().last().cloned()
    }

    /// Check if a variable is configured and allowed
    /// Return the EnvVarConfig for a key. For critical keys enforce
    /// sensitive=true and cacheable=false even if the allowed_vars map is misconfigured.
    fn get_config(&self, key: &str) -> Result<EnvVarConfig> {
        let cfg = self.allowed_vars.get(key).ok_or_else(|| {
            anyhow!("Environment variable {} is not configured for secure access", key)
        })?;

        // Clone and enforce overrides for critical keys.
        let mut cloned = cfg.clone();
        match key {
            "WALLET_MASTER_KEY" | "WALLET_BACKUP_KEY" | "WALLET_BACKUP_OPERATOR_KEY" => {
                cloned.sensitive = true;
                cloned.cacheable = false;
                cloned.max_age_seconds = None;
            }
            _ => {}
        }

        Ok(cloned)
    }

    /// Check permission levels
    fn check_permission(&self, required: &PermissionLevel, provided: &PermissionLevel) -> bool {
        matches!(
            (required, provided),
            (PermissionLevel::Public, _)
                | (
                    PermissionLevel::Internal,
                    PermissionLevel::Internal
                        | PermissionLevel::Sensitive
                        | PermissionLevel::Critical
                )
                | (
                    PermissionLevel::Sensitive,
                    PermissionLevel::Sensitive | PermissionLevel::Critical
                )
                | (PermissionLevel::Critical, PermissionLevel::Critical)
        )
    }

    /// Check if cached value is still valid
    fn is_cache_valid(&self, value: &SecureValue, config: &EnvVarConfig) -> bool {
        if let Some(max_age) = config.max_age_seconds {
            let age = value.created_at.elapsed().as_secs();
            if age > max_age {
                return false;
            }
        }
        true
    }

    /// Audit an operation
    fn audit_operation<F, T>(&self, operation: &str, variable: &str, f: F) -> Result<T>
    where
        F: FnOnce() -> Result<T>,
    {
        let start_time = chrono::Utc::now();
        let result = f();
        let _end_time = chrono::Utc::now();

        let success = result.is_ok();

        // Prepare a redacted detail field for audit entries. Use the
        // `redact_body` helper so full error strings are only revealed when
        // `DEV_PRINT_SECRETS=1` (or test toggles) are set. This avoids
        // embedding arbitrary Debug output in audit records.
        let details = if success {
            "Success".to_string()
        } else {
            let err_str = result
                .as_ref()
                .err()
                .map(|e| e.to_string())
                .unwrap_or_else(|| "Unknown error".to_string());

            // `redact_body` itself checks DEV_PRINT_SECRETS, so call it
            // unconditionally here. If the developer flag is set it will
            // return the full error string; otherwise it returns a
            // redacted placeholder.
            crate::security::redaction::redact_body(&format!("Error: {}", err_str))
        };

        let entry = AuditEntry {
            timestamp: start_time,
            operation: operation.to_string(),
            variable: variable.to_string(),
            success,
            details,
        };

        self.audit_log.lock().unwrap().push(entry);

        // Log security events. Use the redaction helper to avoid leaking
        // sensitive content in logs. This will reveal the error only when
        // developer/testing flags are explicitly enabled.
        if !success {
            let err_display = result
                .as_ref()
                .err()
                .map(|e| e.to_string())
                .unwrap_or_else(|| "<unknown>".to_string());

            let log_err = crate::security::redaction::redact_body(&err_display);
            error!("Security operation failed: {} on {} - {}", operation, variable, log_err);
        } else if matches!(operation, "get_bytes") && variable.contains("MASTER_KEY") {
            info!("Master key accessed securely");
        }

        result
    }
}

impl Default for SecureEnvManager {
    fn default() -> Self {
        Self::new()
    }
}

impl Drop for SecureEnvManager {
    fn drop(&mut self) {
        // Ensure all cached sensitive data is zeroized on drop
        if let Ok(mut cache) = self.secure_cache.lock() {
            for (_, mut value) in cache.drain() {
                value.zeroize();
            }
        }
    }
}

impl ZeroizeOnDrop for SecureValue {}

impl Zeroize for SecureValue {
    fn zeroize(&mut self) {
        self.value.zeroize();
        self.access_count.zeroize();
        // Note: We don't zeroize timestamps as they are not sensitive
    }
}

lazy_static::lazy_static! {
    pub static ref SECURE_ENV_MANAGER: Arc<SecureEnvManager> = Arc::new(SecureEnvManager::new());
}

/// Convenience functions for common operations
pub mod secure_env {
    use super::*;

    /// Get database URL (internal permission)
    pub fn get_database_url() -> Result<String> {
        SECURE_ENV_MANAGER.get_string("DATABASE_URL", PermissionLevel::Internal)
    }

    /// Get API key (sensitive permission) as a zeroizing byte buffer
    /// Returns Zeroizing<Vec<u8>> so callers don't hold plaintext Strings on the heap.
    pub fn get_api_key() -> Result<zeroize::Zeroizing<Vec<u8>>> {
        let v = SECURE_ENV_MANAGER.get_string("API_KEY", PermissionLevel::Sensitive)?;
        Ok(zeroize::Zeroizing::new(v.into_bytes()))
    }

    /// Get wallet master key as bytes (critical permission)
    /// Returns a Zeroizing<Vec<u8>> so the buffer is zeroed on drop.
    pub fn get_wallet_master_key() -> Result<zeroize::Zeroizing<Vec<u8>>> {
        SECURE_ENV_MANAGER.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical)
    }

    /// Get Ethereum RPC URL (public permission)
    pub fn get_ethereum_rpc_url() -> Result<String> {
        SECURE_ENV_MANAGER.get_string("WALLET_ETHEREUM_RPC_URL", PermissionLevel::Public)
    }

    /// Get bridge mock force success flag (internal permission)
    pub fn get_bridge_mock_force_success() -> Result<String> {
        SECURE_ENV_MANAGER.get_string("BRIDGE_MOCK_FORCE_SUCCESS", PermissionLevel::Internal)
    }

    /// Get WALLET_BACKUP_KEY as Zeroizing<Vec<u8>> (base64 32 bytes)
    pub fn get_wallet_backup_key() -> Result<zeroize::Zeroizing<Vec<u8>>> {
        // Read base64 from secure manager as string
        let b64 = SECURE_ENV_MANAGER.get_string("WALLET_BACKUP_KEY", PermissionLevel::Critical)?;
        use base64::engine::general_purpose::STANDARD as B64;
        use base64::Engine as _;
        let raw = B64
            .decode(b64.trim())
            .map_err(|e| anyhow::anyhow!("Invalid base64 for WALLET_BACKUP_KEY: {}", e))?;
        if raw.len() != 32 {
            return Err(anyhow::anyhow!("WALLET_BACKUP_KEY must be 32 bytes"));
        }
        Ok(zeroize::Zeroizing::new(raw))
    }

    /// Get operator key for backups (sensitive) as zeroizing bytes
    pub fn get_wallet_backup_operator_key() -> Result<zeroize::Zeroizing<Vec<u8>>> {
        let v = SECURE_ENV_MANAGER.get_string("WALLET_BACKUP_OPERATOR_KEY", PermissionLevel::Sensitive)?;
        Ok(zeroize::Zeroizing::new(v.into_bytes()))
    }

    /// Clear all cached sensitive values
    pub fn clear_sensitive_cache() -> Result<()> {
        SECURE_ENV_MANAGER.clear_all_cache()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;
    use std::sync::Mutex;

    lazy_static::lazy_static! {
        // Serialize tests that manipulate environment variables to avoid
        // data races when running tests in parallel.
        static ref TEST_ENV_LOCK: Mutex<()> = Mutex::new(());
    }

    #[test]
    fn test_secure_env_manager_creation() {
        let manager = SecureEnvManager::new();
        assert!(!manager.allowed_vars.is_empty());
    }

    #[test]
    fn test_permission_levels() {
        let manager = SecureEnvManager::new();

        // Test permission hierarchy
        assert!(manager.check_permission(&PermissionLevel::Public, &PermissionLevel::Public));
        assert!(manager.check_permission(&PermissionLevel::Internal, &PermissionLevel::Critical));
        assert!(manager.check_permission(&PermissionLevel::Sensitive, &PermissionLevel::Critical));
        assert!(manager.check_permission(&PermissionLevel::Critical, &PermissionLevel::Critical));

        // Test insufficient permissions
        assert!(!manager.check_permission(&PermissionLevel::Critical, &PermissionLevel::Internal));
        assert!(!manager.check_permission(&PermissionLevel::Sensitive, &PermissionLevel::Internal));
    }

    #[test]
    fn test_secure_value_zeroize() {
        let mut value = SecureValue {
            value: Zeroizing::new(vec![1, 2, 3, 4]),
            created_at: std::time::Instant::now(),
            access_count: 5,
            last_accessed: std::time::Instant::now(),
        };

        value.zeroize();

        // Check that the vector is cleared (zeroize for Vec clears it)
        assert!(value.value.is_empty() || value.value.iter().all(|&x| x == 0));
        assert_eq!(value.access_count, 0);
    }

    #[test]
    fn test_audit_logging() {
        let manager = SecureEnvManager::new();

        // Try to access a variable that definitely doesn't exist
        let result = manager.get_string("NON_EXISTENT_TEST_VAR_12345", PermissionLevel::Internal);
        assert!(result.is_err()); // Ensure it actually fails

        let log = manager.get_audit_log();
        assert!(!log.is_empty());

        let last_entry = log.last().unwrap();
        assert_eq!(last_entry.operation, "get_string");
        assert_eq!(last_entry.variable, "NON_EXISTENT_TEST_VAR_12345");
        assert!(!last_entry.success); // Should fail because env var doesn't exist
    }

    #[test]
    fn test_unconfigured_variable_access() {
        let manager = SecureEnvManager::new();

        // Try to access a variable that's not in the allowed list
        let result = manager.get_string("UNCONFIGURED_VAR", PermissionLevel::Public);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("not configured for secure access"));
    }

    #[test]
    fn test_insufficient_permissions() {
        let manager = SecureEnvManager::new();

        // Try to access a critical variable with insufficient permissions
        let result = manager.get_string("WALLET_MASTER_KEY", PermissionLevel::Public);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("Insufficient permissions"));
    }

    #[test]
    fn test_hex_decoding_validation() {
    // Set up a test environment variable with exactly 64 hex characters (32 bytes)
    let hex_value = "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
    let _guard = TEST_ENV_LOCK.lock().unwrap();
    env::set_var("WALLET_MASTER_KEY", hex_value);

    let manager = SecureEnvManager::new();
    let result = manager.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical);

    // Clean up
    env::remove_var("WALLET_MASTER_KEY");

        // Debug: print the result for troubleshooting (use tracing to avoid stderr leaks)
        if let Err(ref e) = result {
            tracing::debug!("Test failed with error: {}", e);
        }

        assert!(result.is_ok(), "Expected successful decoding, got: {:?}", result.err());
        let bytes = result.unwrap();
        assert_eq!(bytes.len(), 32);
    }

    #[test]
    fn test_invalid_hex_format() {
    // Set up invalid hex
    let _guard = TEST_ENV_LOCK.lock().unwrap();
    env::set_var("WALLET_MASTER_KEY", "invalid_hex_value");

    let manager = SecureEnvManager::new();
    let result = manager.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical);

    // Clean up
    env::remove_var("WALLET_MASTER_KEY");

        assert!(result.is_err());
        let error_msg = result.unwrap_err().to_string();
        assert!(error_msg.contains("Invalid hex format") || error_msg.contains("Invalid hex"));
    }

    #[test]
    fn test_wrong_key_length() {
        // Set up wrong length hex (30 bytes instead of 32)
        let _guard = TEST_ENV_LOCK.lock().unwrap();
        env::set_var(
            "WALLET_MASTER_KEY",
            "1234567890abcdef1234567890abcdef1234567890abcdef12345678",
        );

        let manager = SecureEnvManager::new();
        let result = manager.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical);

        // Clean up
        env::remove_var("WALLET_MASTER_KEY");

        assert!(result.is_err());
        let error_msg = result.unwrap_err().to_string();
        assert!(
            error_msg.contains("must be exactly 64 hex characters")
                || error_msg.contains("32 bytes")
        );
    }

    #[test]
    fn test_cache_operations() {
        let manager = SecureEnvManager::new();

    // Set up a test variable
    let _guard = TEST_ENV_LOCK.lock().unwrap();
    env::set_var("DATABASE_URL", "sqlite://test.db");

    // First access should work
    let result1 = manager.get_string("DATABASE_URL", PermissionLevel::Internal);
        assert!(result1.is_ok());

        // Second access should also work (may use cache)
        let result2 = manager.get_string("DATABASE_URL", PermissionLevel::Internal);
        assert!(result2.is_ok());
        assert_eq!(result1.unwrap(), result2.unwrap());

        // Clear cache
        let clear_result = manager.clear_cache("DATABASE_URL");
        assert!(clear_result.is_ok());

    // Clean up
    env::remove_var("DATABASE_URL");
    }

    #[test]
    fn test_secure_env_convenience_functions() {
        // Test that convenience functions are accessible
        // Note: These will fail in test environment since env vars aren't set,
        // but we test that the functions exist and can be called

        let _db_result = secure_env::get_database_url();
        let _api_result = secure_env::get_api_key();
        let _key_result = secure_env::get_wallet_master_key();
        let _rpc_result = secure_env::get_ethereum_rpc_url();
        let _mock_result = secure_env::get_bridge_mock_force_success();

        // Test cache clearing
        let _clear_result = secure_env::clear_sensitive_cache();
    }

    #[test]
    fn test_hex_decoding_with_0x_and_whitespace() {
        // 0x-prefixed and whitespace-surrounded hex should decode correctly
        let hex_value = "  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef  ";
        std::env::set_var("WALLET_MASTER_KEY", hex_value);

        let manager = SecureEnvManager::new();
        let result = manager.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical);

        std::env::remove_var("WALLET_MASTER_KEY");

        assert!(result.is_ok());
        let bytes = result.unwrap();
        assert_eq!(bytes.len(), 32);
    }
}
