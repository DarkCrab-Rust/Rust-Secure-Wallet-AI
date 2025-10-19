#!/usr/bin/env python3
"""Scan Rust source files for public functions that may expose secrets.

This script looks for `pub fn NAME(...) -> ...` patterns and flags
functions whose name contains sensitive keywords (mnemonic|master|private|seed|key|backup|secret|wallet|operator)
and whose return type includes `Vec<u8>` or `String`, unless the return type
already wraps the bytes in a zeroizing type such as `Zeroizing` or `SecretVec`.

Exit code 0 when no issues were found. Exit code 2 when findings were detected.
"""
from pathlib import Path
import re
import sys

ROOT = Path("src")
ALLOWLIST_PATH = Path('.ci/secret_allowlist.txt')
KEYWORDS = {"mnemonic", "master", "private", "seed", "key", "backup", "secret", "wallet", "operator"}

# Matches simple single-line function signatures like:
# pub fn foo(bar: &str) -> Result<Vec<u8>, Error>
# pub fn baz() -> Vec<u8>
FN_RE = re.compile(r'(?m)^\s*pub\s+fn\s+(?P<name>[A-Za-z0-9_]+)\s*\([^)]*\)\s*->\s*(?P<ret>[^\{;\n]+)')

def load_allowlist():
    allow = []
    if ALLOWLIST_PATH.exists():
        for ln in ALLOWLIST_PATH.read_text(encoding='utf-8').splitlines():
            ln = ln.strip()
            if not ln or ln.startswith('#'):
                continue
            allow.append(ln)
    return allow

allowlist = load_allowlist()

findings = []

for path in ROOT.rglob("*.rs"):
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        continue
    for m in FN_RE.finditer(text):
        name = m.group("name")
        ret = m.group("ret").strip()
        lname = name.lower()
        if not any(k in lname for k in KEYWORDS):
            continue

        # If the return type already contains zeroizing wrappers, skip it
        if any(x in ret for x in ("Zeroizing", "SecretVec", "zeroize::Zeroizing")):
            continue

        # Flag functions that return Vec<u8> or String (including nested Result<...>)
        if "Vec<u8>" in ret or "Vec < u8" in ret or "String" in ret:
            lineno = text[: m.start()].count("\n") + 1
            entry = (str(path), lineno, name, ret)
            # If allowlist contains a matching literal pattern, skip
            matched = False
            for a in allowlist:
                # allowlist entries can match file path or a signature-like prefix
                if a in str(path) or a in f"{str(path)}:pub fn {name}" or a in name:
                    matched = True
                    break
            if not matched:
                findings.append(entry)

if findings:
    print("Detected public functions that may expose secret material in memory:")
    for f in findings:
        print(f"{f[0]}:{f[1]}: pub fn {f[2]} -> {f[3]}")
    print()
    print("Please migrate these functions to return a zeroizing secret type (e.g. SecretVec / zeroize::Zeroizing<Vec<u8>>) or confirm they are safe ciphertext/IDs.")
    sys.exit(2)

print("No problematic public secret-returning functions found.")
sys.exit(0)
