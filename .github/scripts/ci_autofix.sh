#!/usr/bin/env bash
# NOTE: On Windows the executable bit may not be preserved; GitHub Actions will still run this with bash.
set -euo pipefail

# Enhanced auto-fix script:
# - apply cargo fmt and cargo fix
# - commit & push if changes
# - call Actions API to rerun the failed workflow
# - poll the rerun until completion; if still failing, retry up to MAX_ATTEMPTS

REPO_DIR=$(pwd)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
OWNER_REPO=${GITHUB_REPOSITORY:-}
if [ -z "$OWNER_REPO" ]; then
  # derive from origin URL
  ORIG_URL=$(git remote get-url origin || true)
  # support git@github.com:owner/repo.git and https://github.com/owner/repo.git
  if [[ "$ORIG_URL" =~ :([^/]+)/([^/]+)\.git$ ]]; then
    OWNER=${BASH_REMATCH[1]}
    REPO=${BASH_REMATCH[2]}
    OWNER_REPO="${OWNER}/${REPO}"
  elif [[ "$ORIG_URL" =~ /([^/]+)/([^/]+)\.git$ ]]; then
    OWNER=${BASH_REMATCH[1]}
    REPO=${BASH_REMATCH[2]}
    OWNER_REPO="${OWNER}/${REPO}"
  else
    echo "Could not determine OWNER/REPO from GITHUB_REPOSITORY or git remote" >&2
    OWNER_REPO="unknown/unknown"
    OWNER="unknown"
    REPO="unknown"
  fi
else
  OWNER=${OWNER_REPO%%/*}
  REPO=${OWNER_REPO#*/}
fi
EVENT_FILE=${GITHUB_EVENT_PATH:-}

if [ -z "$EVENT_FILE" ]; then
  echo "GITHUB_EVENT_PATH not set; cannot determine workflow run context" >&2
  # continue but mark as no-api mode
  SKIP_API=1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not installed; skipping GitHub API operations and performing local fixes only"
  SKIP_API=1
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN not set or empty; skipping GitHub API operations and performing local fixes only"
  SKIP_API=1
fi

if [ -z "${SKIP_API:-}" ]; then
  ORIG_RUN_ID=$(jq -r .workflow_run.id < "$EVENT_FILE")
  WORKFLOW_ID=$(jq -r .workflow_run.workflow_id < "$EVENT_FILE")
fi

MAX_ATTEMPTS=3
SLEEP_POLL=8

function do_local_fix() {
  echo "Running cargo fmt and cargo fix"
  cargo fmt --all
  cargo fix --all --allow-dirty --allow-staged || true
  if ! git diff --quiet; then
    echo "Found changes after autofix; committing"
    git config user.name "github-actions[bot]"
    git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git add -A
    git commit -m "chore(ci): auto-apply rustfmt/cargo-fix from CI autofix"
    git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${OWNER}/${REPO}.git" "HEAD:${BRANCH}"
    return 0
  else
    echo "No local autofix changes"
    return 1
  fi
}

function rerun_workflow() {
  local run_id="$1"
  echo "Requesting rerun for workflow run ${run_id}"
  curl -s -X POST -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${OWNER}/${REPO}/actions/runs/${run_id}/rerun"
}

function poll_latest_run_for_workflow() {
  # Returns the latest run id for the workflow on this branch
  local workflow_id="$1"
  # Query the workflow runs for this workflow id and branch
  local runs_json
  runs_json=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${workflow_id}/runs?branch=${BRANCH}&per_page=5")
  echo "$runs_json" | jq -r '.workflow_runs[] | select(.head_branch==env.BRANCH) | .id' | head -n1
}

function get_run_status() {
  local run_id="$1"
  curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${OWNER}/${REPO}/actions/runs/${run_id}" | jq -r '.status, .conclusion'
}

if [ -z "${SKIP_API:-}" ]; then
  echo "Autofix: origin run id=${ORIG_RUN_ID}, workflow_id=${WORKFLOW_ID}, branch=${BRANCH}"
else
  echo "Autofix: running in local-only mode; branch=${BRANCH}"
fi

attempt=1
while [ $attempt -le $MAX_ATTEMPTS ]; do
  echo "Autofix attempt ${attempt}/${MAX_ATTEMPTS}"

  if [ -n "${SKIP_API:-}" ]; then
    # Only perform local fixes and exit accordingly
    if do_local_fix; then
      echo "Local fixes applied (no API); exiting"
      exit 0
    else
      echo "No local fixes applied and API unavailable; exiting with code 1"
      exit 1
    fi
  fi

  do_local_fix || echo "No local fixes to push"

  # Trigger a rerun of the original failed run
  rerun_workflow "${ORIG_RUN_ID}"

  # Wait a short moment for the new run to be created
  sleep 3

  # Find the newest run for this workflow on this branch
  NEW_RUN_ID=$(poll_latest_run_for_workflow "${WORKFLOW_ID}")
  if [ -z "$NEW_RUN_ID" ] || [ "$NEW_RUN_ID" = "null" ]; then
    echo "Could not find new run id for workflow ${WORKFLOW_ID} on branch ${BRANCH}"
    exit 1
  fi
  echo "Monitoring rerun id: ${NEW_RUN_ID}"

  # Poll until completed
  while true; do
    read -r status conclusion <<<"$(get_run_status "$NEW_RUN_ID")"
    echo "Run ${NEW_RUN_ID} status=${status} conclusion=${conclusion}"
    if [ "$status" = "completed" ]; then
      break
    fi
    sleep $SLEEP_POLL
  done

  if [ "$conclusion" = "success" ]; then
    echo "Rerun ${NEW_RUN_ID} succeeded. Exiting with success."
    exit 0
  else
    echo "Rerun ${NEW_RUN_ID} concluded with '${conclusion}'"
    attempt=$((attempt + 1))
    # Try to apply fixes again in next loop iteration
  fi
done

echo "All ${MAX_ATTEMPTS} attempts exhausted; leaving CI failed for human review"
exit 2
