#!/bin/bash
set -e  # Exit on error

REPO="Yinhang3377/Rust-Blockchain-Secure-Wallet"  # 替换为你的实际repo owner/repo
mkdir -p gha_logs
rm -rf gha_logs/*  # 清空旧日志

echo "Fetching recent failed workflow runs from $REPO..."

# 获取最近1个失败的workflow run ID
RUN_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs?status=failure&per_page=1" | \
  jq -r '.[0].id')

if [ "$RUN_ID" = "null" ]; then
  echo "No recent failed runs found. Exiting."
  exit 0
fi

echo "Latest failed run ID: $RUN_ID"

# 获取run下的所有jobs
JOBS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/jobs" | jq -r '.[].id')

TOTAL_JOBS=$(echo "$JOBS" | wc -l)
FAILED_JOBS=0
echo "TOTAL_JOBS: $TOTAL_JOBS"

# 循环下载每个job的日志
for JOB_ID in $JOBS; do
  JOB_NAME=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO/actions/jobs/$JOB_ID" | jq -r '.name')
  LOG_URL="https://api.github.com/repos/$REPO/actions/jobs/$JOB_ID/logs"

  echo "JOB_ID: $JOB_ID NAME: $JOB_NAME LOGS_URL: $LOG_URL"

  # 下载日志
  curl -s -H "Authorization: token $GITHUB_TOKEN" "$LOG_URL" | base64 -d > "gha_logs/job_${JOB_ID}.log"

  # 检查是否失败（简单grep）
  if grep -q "failure\|error" "gha_logs/job_${JOB_ID}.log" 2>/dev/null; then
    ((FAILED_JOBS++))
  fi
done

echo "FAILED_JOBS: $FAILED_JOBS"

# Grep过滤关键错误（针对A/B/C分类：32-byte, feature-matrix, lint/test）
echo ""
echo "---- Grep results (searching for error/fail/panic/32-byte/feature/clippy) ----"
grep -r -E "(error|fail|panic|32-byte|feature[-_]?matrix|clippy|lint|test.*fail)" gha_logs/ 2>/dev/null || echo "No matching errors found."
echo "---- End of grep output ----"

echo "Script complete. Check gha_logs/ for full files."
