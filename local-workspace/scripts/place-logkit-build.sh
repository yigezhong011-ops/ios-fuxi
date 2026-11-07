#!/bin/bash
# Place the log kit's UEFI pieces where fuxi.dsc expects them, then build.
set -uo pipefail
LOG=/root/logkit-build.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

KIT=/root/build/log-kit/Uefi/Common
for base in /root/build/unixnu/package/UniXNUPkg \
            /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg; do
  [ -d "$base" ] || continue
  mkdir -p "$base/Library" "$base/Driver"
  cp -r "$KIT/AdvancedLogViewLib" "$base/Library/" 2>/dev/null
  cp -r "$KIT/AdvancedLogDxe" "$base/Driver/" 2>/dev/null
  echo "--- $base ---"
  ls "$base/Library" "$base/Driver" | head -8
done

echo "--- 确认文件到位 ---"
for f in /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg/Library/AdvancedLogViewLib/AdvancedLogViewLib.inf \
         /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg/Driver/AdvancedLogDxe/AdvancedLogDxe.inf; do
  [ -e "$f" ] && echo "   有 $f" || echo "   缺 $f"
done

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi /root/build/uefi-fuxi --target DEBUG 2>&1 | tail -20
echo "=== $(date) 结束 ==="
ls -l /root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/*.fd 2>/dev/null
