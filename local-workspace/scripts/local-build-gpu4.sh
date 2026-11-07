#!/bin/bash
# The defconfig points the stub archive at ../../../device (the CI layout); make
# the same relative path resolve here, then rebuild.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true

DEV=/root/fuxi/fork-device
OUT=/root/ux2
TREE=$OUT/fuxi/tree
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi

ln -sfn "$DEV" /root/device
echo "=== 相对路径校验 ==="
ls -l /root/ux2/fuxi/tree/../../../device/build/fuxi-link-stubs/libFuxiLinkStubs.a 2>&1 | head -2

echo "=== 上次链接错误（前几条未定义符号）==="
grep -o '"[_a-z][_a-z0-9]*", referenced' "$TREE/../logs/kernel-bootstrap.log" 2>/dev/null | sort -u | head -12

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-build.log
: > "$LOG"
echo "=== 重新编译 ==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "kernel exit=$code"
grep -n 'error:' "$LOG" 2>/dev/null | head -5 | cut -c1-170
tail -10 "$LOG" | cut -c1-170
