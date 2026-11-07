#!/bin/bash
# Final payload: daily kernel (buttons + DSI brightness) with the wallpaper addon, and a
# command line under the 1000-byte limit: the daily's own 43 arguments minus the
# diagnostics switch.
set -uo pipefail
LOG=/root/rebuild-payload.log
exec >>"$LOG" 2>&1
echo "=== $(date) 第三次 payload 开始 ==="

W=/root/rebuild
TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
cd "$TREE" || exit 1

# the daily's arguments, without the diagnostics switch
grep -v '^armcpu-diagnostics=1$' "$W/args-daily.txt" | tr ' ' '\n' | grep -v '^$' > "$W/args-final.txt"
LEN=$(tr '\n' ' ' < "$W/args-final.txt" | wc -c)
echo "参数 $(wc -l < "$W/args-final.txt") 个，命令行 $LEN 字节"

./unixnu defconfig fuxi_full_defconfig -D "$DEV" 2>&1 | tail -1

set --
while IFS= read -r a; do set -- "$@" "--kernel-arg=$a"; done < "$W/args-final.txt"

./unixnu build payload -D "$DEV" \
  --kernel "$W/kernel-daily.macho" \
  --gpu-addon "$W/addon.ngpu" \
  --trust-cache "$W/trustcache" \
  --data-ramdisk "$W/data.img" \
  --unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}" \
  "$@" 2>&1 | tail -10
echo "=== $(date) 结束 ==="
