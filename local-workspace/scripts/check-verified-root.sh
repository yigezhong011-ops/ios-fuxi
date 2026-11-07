#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== 谁写 verified-root 归档 ==="
grep -rn 'verified-root' "$T/scripts/build-arm-driver.py" 2>/dev/null | head -8 | cut -c1-170
echo
echo "=== 内核脚本期望的路径 ==="
grep -rn 'VERIFIED_ROOT_ARCHIVE\|verified-root' "$T/scripts/build-xnu-4k-baseline.sh" 2>/dev/null | head -8 | cut -c1-170
