#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
echo "=== setup-toolchain.py 说明与步骤 ==="
head -60 "$B/scripts/linux/setup-toolchain.py" 2>/dev/null
echo
echo "=== 有没有 xcrun 包装 ==="
grep -rn 'xcrun' "$B/scripts/linux/"*.py "$B/scripts/linux/"cc "$B/scripts/linux/"clang 2>/dev/null | head -8
ls "$B/scripts/linux/" | wc -l
