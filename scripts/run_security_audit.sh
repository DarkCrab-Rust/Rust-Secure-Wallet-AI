#!/bin/bash

echo "=========================================="
echo " P2 Week 4: Cryptographic Security Audit"
echo "=========================================="
echo ""

echo "1. Running cargo audit for vulnerability scan..."
echo "----------------------------------------------"
cargo audit

echo ""
echo "2. Checking for unsafe code blocks..."
echo "----------------------------------------------"
grep -r "unsafe" src/ --include="*.rs" | wc -l
echo "Unsafe blocks found (review each carefully)"

echo ""
echo "3. Checking for hardcoded secrets..."
echo "----------------------------------------------"
grep -r -i "password\|secret\|key\|token" src/ --include="*.rs" | grep -v "// " | grep -v "/\*" | wc -l
echo "Potential hardcoded secrets (review manually)"

echo ""
echo "4. Checking zeroization usage..."
echo "----------------------------------------------"
grep -r "Zeroize\|zeroize" src/crypto/ src/security/ --include="*.rs" | wc -l
echo "Zeroization implementations found"

echo ""
echo "5. Checking constant-time comparisons..."
echo "----------------------------------------------"
grep -r "constant_time\|ct_eq" src/ --include="*.rs" | wc -l
echo "Constant-time comparison uses"

echo ""
echo "=========================================="
echo " Security Audit Complete!"
echo "=========================================="

