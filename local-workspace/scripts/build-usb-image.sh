#!/bin/bash
# Build the payload with the arguments that booted (no data-reset), then wrap it with the
# new firmware that powers the USB controller.
set -uo pipefail
LOG=/root/usb-image.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) ==="

W=/root/rebuild
TREE=/root/build/unixnu
DEV=/root/build/fuxi
U=/root/build/uefi-fuxi

# the arguments that booted before the data-reset experiment
cp -f "$W/args-final.bak" "$W/args-final.txt"
grep -q 'sheng-data-reset' "$W/args-final.txt" && echo "警告: 还带着 data-reset"

echo "--- 打包附加包（壁纸 + WidgetRenderer_Default）---"
python3 /mnt/e/DSH-Fuxi/dump/wsl/pack-addon.py /root/fuxi/addon-new/plugin "$W/addon-usb.ngpu" \
  --clients 'SpringBoard,WidgetRenderer_Default' --wallpaper /root/wallpaper-overlay --publish 2>&1 | tail -2

echo "--- 构建载荷 ---"
cd "$TREE" || exit 1
./unixnu defconfig fuxi_full_defconfig -D "$DEV" >/dev/null 2>&1
set --
while IFS= read -r a; do set -- "$@" "--kernel-arg=$a"; done < "$W/args-final.txt"
./unixnu build payload -D "$DEV" \
  --kernel "$W/kernel-daily.macho" \
  --gpu-addon "$W/addon-usb.ngpu" \
  --trust-cache "$W/trustcache" \
  --data-ramdisk "$W/data.img" \
  --unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}" \
  "$@" 2>&1 | tail -3

echo "--- 用新固件打包 ---"
bash /root/fuxi/pwf.sh "$U/BootShim/BootShim.bin" \
  "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd" \
  "$TREE/out/fuxi/payload/payload.img" t32-usb 2>&1 | tail -3

echo "=== $(date) 结束 ==="
