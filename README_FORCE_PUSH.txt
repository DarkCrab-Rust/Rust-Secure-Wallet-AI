========================================
Force Overwrite GitHub Main Branch
========================================

STEP 1: Force Overwrite GitHub Main Branch
----------------------------------------

cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
bash force_overwrite_github_main.sh

This will:
- Overwrite GitHub main branch with your local code
- Requires confirmation: type YES then FORCE
- After completion, local and GitHub will be identical


STEP 2: Delete All Useless Branches
----------------------------------------

bash delete_all_branches.sh

This will:
- Delete all branches except main
- Requires confirmation: type YES
- After completion, only main branch remains


STEP 3: Set Main as Default Branch (Manual)
----------------------------------------

Visit:
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet/settings/branches

Set "main" as default branch


VERIFICATION
----------------------------------------

Visit:
https://github.com/Yinhang3377/Rust-Blockchain-Secure-Wallet

You should see:
- Only main branch
- All your files
- Code identical to local


QUICK COMMANDS
----------------------------------------

# Complete overwrite in two steps:
cd /c/Users/plant/Desktop/Rust区块链/Rust-Blockchain-Secure-Wallet
bash force_overwrite_github_main.sh
bash delete_all_branches.sh

========================================

