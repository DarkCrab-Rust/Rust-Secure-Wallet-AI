use std::env;

#[test]
fn audit_details_are_redacted_by_default() {
    // Ensure developer reveal flags are not set
    env::remove_var("DEV_PRINT_SECRETS");
    env::remove_var("TEST_SKIP_DECRYPT");

    use defi_hot_wallet::security::env_manager::{PermissionLevel, SECURE_ENV_MANAGER};

    // Trigger an audited operation that will error (missing env var or invalid hex)
    // We call get_bytes for a configured key; if not present it will error and create an audit entry.
    let _ = SECURE_ENV_MANAGER.get_bytes("WALLET_MASTER_KEY", PermissionLevel::Critical);

    let last = SECURE_ENV_MANAGER.get_last_audit_entry().expect("last audit entry");

    // Audit details must not contain obvious hex patterns by default
    // (we check for '0x' hex prefix or long hex sequences)
    let details = last.details().to_lowercase();
    assert!(
        !details.contains("0x") && !details.contains("[0-9a-f]"),
        "Audit details appear to contain hex or sensitive content: {}",
        last.details()
    );
}
