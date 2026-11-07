#!/bin/bash
# Supply TargetConditionals.h to the freshly assembled tree and continue.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true

DEV=/root/fuxi/fork-device
OUT=/root/ux2
TREE=$OUT/fuxi/tree
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi

echo "=== 补 TargetConditionals.h ==="
for d in \
  "$TREE/.cache/fakeroot/usr/include" \
  "$TREE/.cache/fakeroot/usr/local/include" \
  "$TREE/.cache/fakeroot/usr/local/include/kernel" \
  "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/Headers" \
  "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/PrivateHeaders" \
  "$TREE/.cache/xnu-work/EXTERNAL_HEADERS" \
  /opt/unixnu-linux/CommandLineTools/SDKs/MacOSX.sdk/usr/include ; do
  mkdir -p "$d" 2>/dev/null
  cp -f "$SRC" "$d/TargetConditionals.h" 2>/dev/null
done
find "$TREE/.cache/fakeroot" -name TargetConditionals.h 2>/dev/null | head -4

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-build.log
: > "$LOG"
echo "=== 继续编译 ==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "kernel exit=$code"
echo "=== 错误 ==="
grep -n 'error:' "$LOG" 2>/dev/null | head -6 | cut -c1-170
echo "=== 尾部 ==="
tail -12 "$LOG" | cut -c1-170
