#!/bin/bash
# Build a fresh payload with the wallpaper addon, reproducing t32's boot arguments.
# The arguments are passed as --kernel-arg=NAME so values that start with '-' are not
# mistaken for options.
set -uo pipefail
LOG=/root/rebuild-payload.log
exec >>"$LOG" 2>&1
echo "=== $(date) payload 开始 ==="

TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
W=/root/rebuild
cd "$TREE" || exit 1

./unixnu defconfig fuxi_full_defconfig -D "$DEV" 2>&1 | tail -2

ARGS=$(cat "$W/args.txt")
set -- 
for a in $ARGS; do
  set -- "$@" "--kernel-arg=$a"
done
echo "参数个数: $#"

./unixnu build payload -D "$DEV" \
  --kernel /root/fuxi/t32/kernel.macho \
  --gpu-addon "$W/addon.ngpu" \
  --trust-cache "$W/trustcache" \
  --data-ramdisk "$W/data.img" \
  --unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}" \
  "$@" 2>&1 | tail -25

echo "--- 结果 ---"
find out -name 'payload.img' 2>/dev/null | head -3
ls -l out/*/*/*/payload/payload.img 2>/dev/null
echo "=== $(date) payload 结束 ==="
