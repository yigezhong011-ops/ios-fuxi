#!/bin/bash
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true
T=/root/ux2/fuxi/tree
echo "=== 找 noctf / mach 产物 ==="
find "$T/build/xnu" -name 'mach.development*' 2>/dev/null | head -6
echo
echo "=== 试着 prelink ==="
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
./unixnu build prelink -D /root/fuxi/fork-device --out /root/ux2 --uefi /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi 2>&1 | tail -8 | cut -c1-170
echo
echo "=== 产物 ==="
ls -l /root/ux2/fuxi/kernel/ 2>/dev/null | head -5
ls -l /root/ux2/fuxi/tree/build/native-prelink/ 2>/dev/null | head -5
