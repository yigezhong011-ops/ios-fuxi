#!/bin/bash
set -uo pipefail
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
echo "=== 新的 iPadOS 17 profile ==="
git show origin/main:profiles/os/ipados-17.7.11-21H461/profile.toml 2>/dev/null | head -30 | cut -c1-150
echo
echo "=== 新代码里的 owner boot manifest ==="
git grep -l 'owner boot manifest\|owner_boot_manifest\|os_volume_uuid' origin/main -- '*.py' '*.toml' '*.md' 2>/dev/null | head -10 | cut -c1-140
