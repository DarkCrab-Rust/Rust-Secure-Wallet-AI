#!/usr/bin/env bash
# NOTE: On Windows the executable bit may not be preserved; GitHub Actions will still run this with bash.
set -euo pipefail

# Minimal auto-fix script: only run non-invasive fixes and push if there are changes.
# Safety: uses GITHUB_TOKEN to push back to the same branch. It will not change tests or logic.

REPO_DIR=$(pwd)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
ORIGIN=$(git remote get-url origin)

echo "Running cargo fmt and cargo fix on branch ${BRANCH}"

# Run formatter and fix suggestions
cargo fmt --all
# Allow cargo fix to modify code. --allow-staged/--allow-dirty allow committing changes made by the script.
cargo fix --all --allow-dirty --allow-staged || true

# If there are changes, commit and push
if ! git diff --quiet; then
  git config user.name "github-actions[bot]"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git add -A
  git commit -m "chore(ci): auto-apply rustfmt/cargo-fix from CI autofix"
  # Push using token
  git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" "HEAD:${BRANCH}"
  echo "Pushed fixes to ${BRANCH}"
else
  echo "No autofix changes detected"
fi
