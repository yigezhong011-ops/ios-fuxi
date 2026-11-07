#!/bin/bash
# Build a boot image from scratch: addon with the given client list (and the wallpaper),
# a fresh payload with the daily kernel and arguments, packed with the working loader.
# Usage: build-wall-variant.sh <out-name> <clients>
set -uo pipefail
OUT=$1
CLIENTS=$2
W=/root/rebuild
TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi

echo "=== 1. 打包附加包（名单：$CLIENTS） ==="
python3 /mnt/e/DSH-Fuxi/dump/wsl/pack-addon.py /root/fuxi/addon-new/plugin "$W/addon-$OUT.ngpu" \
  --clients "$CLIENTS" --wallpaper /root/wallpaper-overlay --publish 2>&1 | tail -2

echo "=== 2. 重建载荷 ==="
cd "$TREE" || exit 1
./unixnu defconfig fuxi_full_defconfig -D "$DEV" >/dev/null 2>&1
set --
while IFS= read -r a; do set -- "$@" "--kernel-arg=$a"; done < "$W/args-final.txt"
./unixnu build payload -D "$DEV" \
  --kernel "$W/kernel-daily.macho" \
  --gpu-addon "$W/addon-$OUT.ngpu" \
  --trust-cache "$W/trustcache" \
  --data-ramdisk "$W/data.img" \
  --unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}" \
  "$@" 2>&1 | tail -3

echo "=== 3. 打包启动镜像 ==="
bash /root/fuxi/pack-payload.sh "$TREE/out/fuxi/payload/payload.img" "$OUT" 2>&1 | tail -3
