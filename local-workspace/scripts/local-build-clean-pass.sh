#!/bin/bash
# Fresh full pass: the patch series changed, so stale objects must go.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true
DEV=/root/fuxi/fork-device
OUT=/root/ux2
TREE=$OUT/fuxi/tree
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h

echo "=== 清理 XNU 构建产物 ==="
rm -rf "$TREE/build/xnu"
du -sh "$TREE/.cache/xnu-work" 2>/dev/null

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-build.log
: > "$LOG"
echo "=== 完整编译（-j8）==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j8 >>"$LOG" 2>&1
echo "kernel exit=$?"
echo "=== error ==="
grep -an 'error:' "$LOG" | head -4 | cut -c1-175
echo "=== archive 进度 ==="
grep -a 'kernel: archive' "$LOG" | tail -3
tail -6 "$LOG" | cut -c1-170
