#!/bin/bash
# Rebuild in WSL's native filesystem, re-supplying TargetConditionals.h whenever
# the tree is recreated (the firehose step includes it unconditionally).
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1

OUT=/root/ux-out
TREE=$OUT/fuxi/tree
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/kernel-ext4.log

supply() {
  for d in \
    "$TREE/.cache/fakeroot/usr/include" \
    "$TREE/.cache/fakeroot/usr/local/include" \
    "$TREE/.cache/fakeroot/usr/local/include/kernel" \
    "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/Headers" \
    "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/PrivateHeaders" \
    "$TREE/.cache/xnu-work/EXTERNAL_HEADERS" ; do
    [ -d "$d" ] || mkdir -p "$d"
    cp -f "$SRC" "$d/TargetConditionals.h" 2>/dev/null || true
  done
  echo "  已补充 TargetConditionals.h"
}

for round in 1 2 3; do
  echo "== 第 $round 轮构建（$(date +%H:%M)）"
  : > "$LOG"
  ./unixnu build kernel --out "$OUT" -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
  code=$?
  echo "   退出码 $code"
  if [ "$code" = 0 ]; then
    echo "== 构建成功 =="
    find "$OUT" -name 'kernel.macho' 2>/dev/null | head -3
    break
  fi
  if grep -q "TargetConditionals.h' file not found" "$LOG"; then
    supply
    continue
  fi
  echo "== 其它错误，停止 =="
  tail -18 "$LOG"
  break
done
