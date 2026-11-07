#!/bin/bash
# The log kit keeps AdvancedLogViewLib.h inside the library directory; UniXNUPkg needs it
# under Include/Library for the DEC entry to resolve.
set -uo pipefail
LOG=/root/logkit-build.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) ==="

echo "--- 在 kit 里找这个头文件 ---"
find /root/build/log-kit -name 'AdvancedLogViewLib.h' 2>/dev/null

SRC=$(find /root/build/log-kit -name 'AdvancedLogViewLib.h' 2>/dev/null | head -1)
if [ -z "$SRC" ]; then echo "找不到，停止"; exit 1; fi

for base in /root/build/unixnu/package/UniXNUPkg \
            /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg; do
  mkdir -p "$base/Include/Library"
  cp "$SRC" "$base/Include/Library/AdvancedLogViewLib.h"
  echo "   已放到 $base/Include/Library/"
done

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi /root/build/uefi-fuxi --target DEBUG 2>&1 | tail -18
echo "=== $(date) 结束 ==="
ls -l /root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/*.fd 2>/dev/null
