#!/bin/bash
set -uo pipefail
F=/root/ux3/fuxi/tree/drivers/GopFramebuffer/NativeLegacyDisplay.cpp
echo "=== boot_progress_bind 的调用 ==="
grep -n 'boot_progress_bind' "$F" | head -5 | cut -c1-190
n=$(grep -n 'boot_progress_bind' "$F" | head -1 | cut -d: -f1)
[ -n "${n:-}" ] && awk -v s=$((n>8?n-8:1)) -v e=$((n+6)) 'NR>=s && NR<=e {printf "%4d| %s\n", NR, $0}' "$F" | cut -c1-175
echo
echo "=== 帧缓冲几何来源 ==="
grep -n 'rowBytes\|rowbytes\|stride\|bytesPerRow' "$F" | head -10 | cut -c1-175
