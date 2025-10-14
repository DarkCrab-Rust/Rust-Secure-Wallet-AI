ARCHIVE - Removed / archived modules

This file lists directories and files that were moved to `archive/` as part of the "wallet-core-only" split. The core wallet remains in the repository and is intended to be the focus of the migrated repo.

Directories moved to `archive/`:

- docs/               -> archive/docs/
- examples/           -> archive/examples/
- defi-target/        -> archive/defi-target/
- tools/              -> archive/tools/
- vendor/             -> archive/vendor/
- scripts/            -> archive/scripts/
- resources/          -> archive/resources/

Why archived
- These are non-core artifacts (documentation, examples, test build caches, auxiliary scripts and tools) that bloat the repo and are not required for the wallet-core library.

How to restore
- To restore a directory, run:

```bash
git checkout main -- <path>
# or, if you're on the split branch and the path is no longer present on main, you can fetch it from the original remote
git checkout origin/main -- <path>
```

Notes
- `patches/elliptic-curve-tools` is retained in the workspace because tests and internal tooling rely on it.
- Before making any release or publishing this crate, review the `Cargo.toml` workspace members to ensure no removed paths are still referenced.
