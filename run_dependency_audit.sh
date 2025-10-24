#!/bin/bash

echo "=========================================="
echo " P2 Week 6: Dependency Security Audit"
echo "=========================================="
echo ""

echo "1. Installing cargo-audit if not present..."
echo "----------------------------------------------"
cargo install cargo-audit --quiet 2>/dev/null || echo "cargo-audit already installed"

echo ""
echo "2. Running cargo audit for known vulnerabilities..."
echo "----------------------------------------------"
cargo audit --deny warnings

echo ""
echo "3. Checking for outdated dependencies..."
echo "----------------------------------------------"
cargo outdated --root-deps-only || echo "Note: Install with 'cargo install cargo-outdated'"

echo ""
echo "4. Analyzing dependency tree depth..."
echo "----------------------------------------------"
cargo tree --depth 3

echo ""
echo "5. Checking for duplicate dependencies..."
echo "----------------------------------------------"
cargo tree --duplicates

echo ""
echo "6. Counting total dependencies..."
echo "----------------------------------------------"
echo "Direct dependencies:"
grep '^\[dependencies\]' -A 100 Cargo.toml | grep -v '^\[' | grep -v '^#' | grep '=' | wc -l

echo ""
echo "Total dependencies (including transitive):"
cargo tree --depth 999 | wc -l

echo ""
echo "=========================================="
echo " Dependency Audit Complete!"
echo "=========================================="

