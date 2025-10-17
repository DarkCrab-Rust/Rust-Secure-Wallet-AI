Secure logging guidelines

Purpose
Keep sensitive data out of logs and ensure secrets are zeroized in memory after use.

Guidelines
- Do NOT use `println!`, `eprintln!`, or `dbg!` in non-test code. Use `tracing` macros (`trace!`, `debug!`, `info!`, `warn!`, `error!`) with structured fields instead.
- Never log raw secret bytes, private keys, or seed phrases. If you need to log a key's presence, log a redacted fingerprint or public identifier, e.g., the key's address or hashed identifier.
- Prefer `zeroize::Zeroizing<T>` for in-memory secret containers. When returning secret buffers from functions, prefer returning a Zeroizing wrapper to ensure memory is zeroed on drop.
- Tests may use prints for debugging, but prefer `tracing` with a test-specific subscriber or use allowlists in CI.

CI
- Use the `prevent-secret-prints.yml` workflow to block accidental prints or insecure placeholders in PRs.

If you need help migrating an existing print site or wrapping a type with `Zeroizing`, ask in the PR and tag security reviewers.
