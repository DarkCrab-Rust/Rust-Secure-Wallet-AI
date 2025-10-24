#!/bin/bash
# 强制用本地main分支覆盖GitHub的main分支

cd "$(dirname "$0")"

echo "=========================================="
echo "WARNING: Force Overwrite GitHub Main Branch"
echo "=========================================="
echo ""
echo "This will:"
echo "1. Overwrite GitHub main branch with local main branch"
echo "2. GitHub main branch will be identical to local"
echo "3. GitHub main branch history may be lost"
echo ""

# 询问确认
read -p "Continue? (type YES): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Cancelled"
    exit 1
fi

echo ""
echo "[1/8] Checking current branch..."
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Not on main branch, switching to main..."
    git checkout main
    if [ $? -ne 0 ]; then
        echo "Failed to switch"
        exit 1
    fi
    echo "Switched to main branch"
fi
echo ""

echo "[2/8] Checking working directory..."
if [[ -n $(git status -s) ]]; then
    echo "You have uncommitted changes:"
    git status -s
    echo ""
    read -p "Commit these changes? (y/n): " commit_confirm
    if [ "$commit_confirm" = "y" ] || [ "$commit_confirm" = "Y" ]; then
        git add .
        git commit -m "chore: commit all changes before force push"
        echo "Committed"
    else
        echo "Please handle uncommitted changes first"
        exit 1
    fi
else
    echo "Working directory clean"
fi
echo ""

echo "[3/8] Local main branch latest commits:"
git log --oneline -5
echo ""

echo "[4/8] Fetching remote info..."
git fetch origin
echo "Done"
echo ""

echo "[5/8] GitHub main branch latest commits:"
git log origin/main --oneline -5
echo ""

echo "[6/8] Final confirmation..."
echo ""
echo "WARNING WARNING WARNING"
echo ""
echo "About to overwrite GitHub main branch with local main!"
echo "GitHub main branch history may be lost!"
echo ""
read -p "Final confirmation (type FORCE): " final_confirm

if [ "$final_confirm" != "FORCE" ]; then
    echo "Cancelled"
    exit 1
fi

echo ""
echo "[7/8] Force pushing to GitHub main branch..."
echo "Executing: git push origin main --force-with-lease"
echo ""

git push origin main --force-with-lease

if [ $? -eq 0 ]; then
    echo ""
    echo "Successfully overwrote GitHub main branch!"
else
    echo ""
    echo "Push failed!"
    echo ""
    echo "Try stronger force push?"
    read -p "Use --force? (type FORCE): " force_confirm
    if [ "$force_confirm" = "FORCE" ]; then
        git push origin main --force
        if [ $? -eq 0 ]; then
            echo "Force push successful!"
        else
            echo "Force push failed!"
            exit 1
        fi
    else
        echo "Cancelled"
        exit 1
    fi
fi

echo ""
echo "[8/8] Verifying result..."
git fetch origin
BEHIND=$(git rev-list --count HEAD..origin/main)
AHEAD=$(git rev-list --count origin/main..HEAD)

echo "Verification:"
echo "- Local behind GitHub: $BEHIND commits"
echo "- Local ahead GitHub: $AHEAD commits"

if [ $BEHIND -eq 0 ] && [ $AHEAD -eq 0 ]; then
    echo ""
    echo "PERFECT! Local and GitHub main are identical!"
else
    echo "There may still be differences"
fi

echo ""
echo "=========================================="
echo "Overwrite Complete!"
echo "=========================================="
echo ""
echo "GitHub repository:"
echo "https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet"
echo ""
echo "Next steps:"
echo "1. Visit GitHub to verify main branch content"
echo "2. Set main as default branch"
echo "3. Delete unnecessary branches"
echo ""

