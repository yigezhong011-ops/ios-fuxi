#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi/xnu/patches
echo "=== 涉及 pe_serial.c 的补丁 ==="
grep -l 'pexpert/arm/pe_serial.c' *.patch | sort
echo
echo "=== 涉及 fuxi_display_kick 的补丁与行 ==="
grep -n 'fuxi_display_kick' *.patch | head -20
echo
echo "=== 0087 / 0096 里 kick 的形状 ==="
for p in 0087*.patch 0096*.patch; do
  [ -f "$p" ] || continue
  echo "--- $p"
  grep -n -A6 'fuxi_display_kick' "$p" | head -20
done
