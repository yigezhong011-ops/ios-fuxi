#!/bin/bash
# Compiling on /mnt/e (drvfs) is the bottleneck: ~0.6 objects a minute. Move the
# output tree to WSL's native filesystem and rebuild there.
set -uo pipefail
pkill -f 'build-xnu-4k-baseline' 2>/dev/null
pkill -f 'unixnu build kernel' 2>/dev/null
sleep 3

REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1

OUT=/root/ux-out
mkdir -p "$OUT"
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/kernel-ext4.log
: > "$LOG"
echo "== 在 $OUT 上重建（ext4）"
time ./unixnu build kernel --out "$OUT" -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "KERNEL_EXIT=$code"
tail -25 "$LOG"
