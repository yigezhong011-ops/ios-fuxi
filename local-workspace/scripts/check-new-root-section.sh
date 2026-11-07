#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
echo "=== 新 profile 里的 [root] 段 ==="
git show origin/main:profiles/os/ipados-17.7.11-21H461/profile.toml 2>/dev/null | grep -A12 '^\["root"\]' | cut -c1-160
echo
echo "=== patch-reference 里 owner boot manifest 的说明 ==="
git show origin/main:docs/xnu/patch-reference.md 2>/dev/null | grep -B2 -A6 -i 'owner boot manifest' | head -30 | cut -c1-170
