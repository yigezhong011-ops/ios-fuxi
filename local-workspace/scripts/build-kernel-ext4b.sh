#!/bin/bash
# Rebuild the kernel on WSL's native filesystem (drvfs was the bottleneck).
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1

OUT=/root/ux-out
mkdir -p "$OUT"
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/kernel-ext4.log
: > "$LOG"

echo "== 1) 在新输出目录里选配置"
./unixnu defconfig fuxi_full_defconfig --out "$OUT" -D ../fuxi --uefi ../uefi-fuxi >>"$LOG" 2>&1
echo "   defconfig exit=$?"

echo "== 2) 构建内核（ext4，计时）"
time ./unixnu build kernel --out "$OUT" -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "KERNEL_EXIT=$code"
tail -20 "$LOG"
echo
echo "== 产物 =="
find "$OUT" -name 'kernel.macho' -o -name '*.macho' 2>/dev/null | head -5
du -sh "$OUT" 2>/dev/null
