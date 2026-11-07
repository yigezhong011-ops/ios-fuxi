#!/bin/bash
set -uo pipefail
S=/root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh
echo "=== 显示与 PMGR 归档怎么被链接 ==="
grep -n 'NativeLegacyDisplay\|force_load\|legacy-display' "$S" | head -14 | cut -c1-175
