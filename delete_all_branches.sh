#!/bin/bash
# Delete all useless branches on GitHub, keep only main

cd "$(dirname "$0")"

echo "=========================================="
echo "Delete Useless Branches on GitHub"
echo "=========================================="
echo ""
echo "This will delete the following branches:"
echo "- archive-bridge-stub"
echo "- feature/api-improvement"
echo "- feature/api-improvement-fix"
echo "- feature/ci-tests-secretvec"
echo "- feature/cli-secretvec"
echo "- feature/encryption-secretvec"
echo "- feature/new-feature"
echo "- feature/secretvec-foundation"
echo "- security/secretvec-ci"
echo ""
echo "Keep only: main branch"
echo ""

read -p "Delete these branches? (type YES): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Cancelled"
    exit 1
fi

echo ""
echo "Starting to delete branches..."
echo ""

# List of branches to delete (using English names for compatibility)
branches=(
    "archive-bridge-stub"
)

# Try to get actual branch names from remote
echo "Fetching remote branches..."
git fetch origin

# Get all remote branches except main
remote_branches=$(git branch -r | grep -v 'HEAD' | grep -v 'main' | sed 's/origin\///' | tr -d ' ')

success_count=0
fail_count=0

# Delete each remote branch
for branch in $remote_branches; do
    echo "Deleting branch: $branch"
    git push origin --delete "$branch" 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully deleted: $branch"
        ((success_count++))
    else
        echo "Failed or does not exist: $branch"
        ((fail_count++))
    fi
    echo ""
done

echo "=========================================="
echo "Deletion Complete"
echo "=========================================="
echo ""
echo "Successfully deleted: $success_count branches"
echo "Failed or non-existent: $fail_count branches"
echo ""
echo "Now only main branch remains"
echo ""
echo "Verify at:"
echo "https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/branches"
echo ""

