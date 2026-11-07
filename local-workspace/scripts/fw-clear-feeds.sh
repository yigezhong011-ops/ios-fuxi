#!/bin/bash
# The earlier failures left dirty feed checkouts; out/feeds is only a cache, so clear it
# and build the firmware again.
set -uo pipefail
LOG=/root/firmware-native.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

echo "--- 清掉 feeds 缓存 ---"
du -sh /root/build/unixnu/out/feeds 2>/dev/null
rm -rf /root/build/unixnu/out/feeds
echo "   已删除"

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi /root/build/uefi-fuxi --target DEBUG 2>&1 | tail -40
rc=$?
echo "=== $(date) 结束 rc=$rc ==="
ls -l /root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/*.fd 2>/dev/null
