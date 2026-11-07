#!/bin/bash
# The firmware DSC wants UniXNUPkg/Library/AdvancedLogViewLib and Driver/AdvancedLogDxe,
# which ship with the author's log kit rather than this UniXNU checkout. Add them.
set -uo pipefail
LOG=/root/logkit-build.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

KIT=/root/build/log-kit
if [ ! -d "$KIT/.git" ]; then
  git clone -q --depth 1 https://github.com/ljhhkx529/unixnu-log-kit.git "$KIT"
fi
echo "--- log kit 内容 ---"
ls "$KIT" | head -12

PKG=/root/build/unixnu/package/UniXNUPkg
mkdir -p "$PKG/Library" "$PKG/Driver"
for d in AdvancedLogViewLib AdvancedLogDxe; do
  src=""
  for cand in "$KIT/$d" "$KIT/Library/$d" "$KIT/Driver/$d"; do
    [ -d "$cand" ] && src="$cand" && break
  done
  if [ -z "$src" ]; then echo "   $d: 没找到"; continue; fi
  case $d in
    AdvancedLogViewLib) dst="$PKG/Library/$d" ;;
    *) dst="$PKG/Driver/$d" ;;
  esac
  rm -rf "$dst"; cp -r "$src" "$dst"
  echo "   $d: $src -> $dst ($(find "$dst" -type f | wc -l) 个文件)"
done

echo "--- 复查 DSC 引用的文件是否都在 ---"
for f in UniXNUPkg/Library/AdvancedLogViewLib/AdvancedLogViewLib.inf \
         UniXNUPkg/Driver/AdvancedLogDxe/AdvancedLogDxe.inf; do
  if [ -e "/root/build/unixnu/package/$f" ]; then echo "   有: $f"; else echo "   缺: $f"; fi
done

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi /root/build/uefi-fuxi --target DEBUG 2>&1 | tail -25
echo "=== $(date) 结束 ==="
ls -l /root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/*.fd 2>/dev/null
