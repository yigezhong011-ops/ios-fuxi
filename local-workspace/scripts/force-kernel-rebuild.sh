#!/bin/bash
# The tree cached an osfmk compile record from a bootstrap pass that failed, so
# the driver skips the bootstrap and then the archive step finds no
# link.filelist. Drop the cached source tree and the record, then rebuild so the
# portability patches (which fix the host/target flag mixing) actually apply.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
# shellcheck disable=SC1091
source "$REPO/env.sh" || exit 1

OUT=/root/ux-out
TREE=$OUT/fuxi/tree
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/linux/TargetConditionals.h

echo "== 1) 清缓存与记录"
rm -rf "$TREE/.cache/xnu-work" "$TREE/build/xnu" 2>/dev/null
echo "   已删除 xnu-work 与 build/xnu"

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/kernel-ext4.log
: > "$LOG"

for round in 1 2; do
  echo "== 2.$round) 构建（$(date +%H:%M）)"
  ./unixnu build kernel --out "$OUT" -D ../fuxi --uefi ../uefi-fuxi -j"$(nproc)" >>"$LOG" 2>&1
  code=$?
  echo "   退出码 $code"
  if [ "$code" = 0 ]; then echo "== 成功 =="; break; fi
  if grep -q "TargetConditionals.h' file not found" "$LOG"; then
    for d in "$TREE/.cache/fakeroot/usr/include" "$TREE/.cache/fakeroot/usr/local/include" \
             "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/Headers" \
             "$TREE/.cache/fakeroot/System/Library/Frameworks/Kernel.framework/PrivateHeaders" \
             "$TREE/.cache/xnu-work/EXTERNAL_HEADERS"; do
      mkdir -p "$d"; cp -f "$SRC" "$d/TargetConditionals.h" 2>/dev/null || true
    done
    echo "   补 TargetConditionals.h 后重试"
    continue
  fi
  echo "== 其它错误 =="
  grep -nE 'unsupported option|\*\*\* ' "$LOG" | head -8
  tail -8 "$LOG"
  break
done

echo
echo "== 补丁是否生效（应有 HOST_CSH）=="
grep -c 'HOST_CSH' "$TREE/.cache/xnu-work/bsd/conf/Makefile" 2>/dev/null || echo 0
echo "== 产物 =="
find "$OUT" -name 'kernel.macho' 2>/dev/null | head -3
find "$TREE" -name 'link.filelist' 2>/dev/null | head -3
