#!/bin/bash
set -uo pipefail
S=/root/fuxi/fork-device/scripts/build-xnu-4k-baseline.sh
echo "=== 是否给 bootstrap pass 传 -D ==="
grep -n 'XNU_BOOTSTRAP' "$S" | head -8 | cut -c1-170
echo
echo "=== EXTRA_CFLAGS 相关 ==="
grep -n 'EXTRA_CFLAGS' "$S" | head -8 | cut -c1-170
echo
echo "=== EXTRA_LD_ARCHIVES 应用位置 ==="
grep -n 'EXTRA_LD_ARCHIVES\|LD_KERNEL_ARCHIVES' "$S" | head -6 | cut -c1-170
