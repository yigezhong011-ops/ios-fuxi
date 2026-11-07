#!/bin/bash
# Serial build so the first real error is readable instead of interleaved.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true
DEV=/root/fuxi/fork-device
OUT=/root/ux2
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
TREE=$OUT/fuxi/tree
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h

# 清理记录，强制 bootstrap 再跑
find "$TREE/build/xnu/ios-obj" -name 'startup.o.json' -delete 2>/dev/null
for d in "$TREE/.cache/fakeroot/usr/include" "$TREE/.cache/fakeroot/usr/local/include" \
         "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/Headers" \
         "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/PrivateHeaders" \
         "$TREE/.cache/xnu-work/EXTERNAL_HEADERS" ; do
  mkdir -p "$d" 2>/dev/null; cp -f "$SRC" "$d/TargetConditionals.h" 2>/dev/null
done

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-serial.log
: > "$LOG"
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j2 >>"$LOG" 2>&1
echo "kernel exit=$?"
echo "=== 前 5 个 error ==="
grep -an 'error:' "$LOG" 2>/dev/null | head -5 | cut -c1-190
echo "=== 尾部 ==="
tail -6 "$LOG" | cut -c1-170
