#!/bin/bash
# Rebuild the firmware with UsbMsdDxe and wrap the t36-bl2 volume into a test image.
set -uo pipefail
LOG=/root/fw-msd.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) ==="
U=/root/build/uefi-fuxi
TREE=/root/build/unixnu

cd "$TREE" || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi "$U" --target DEBUG 2>&1 | tail -12
FD=$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
ls -l "$FD" 2>/dev/null || { echo "没有 FD"; exit 1; }
echo "--- FV 里有没有 UsbMsdDxe ---"
ls "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/Ffs/" | grep -i 'UsbMsd' | head -3

echo "--- 打包（t36 卷 + 新固件）---"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-with-fd.sh > /root/fuxi/pwf.sh
bash /root/fuxi/pwf.sh "$U/BootShim/BootShim.bin" "$FD" /root/fuxi/t36-bl2/vol.img t36-fdmsd 2>&1 | tail -3
echo "--- USB 测试镜像 ---"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t36-usb.sh > /root/fuxi/m36b.sh
sed -i 's#/mnt/e/DSH-Fuxi/t32-usb.img#/mnt/e/DSH-Fuxi/t36-fdmsd.img#g' /root/fuxi/m36b.sh
bash /root/fuxi/m36b.sh t36-usb-msd4 2>&1 | tail -5
echo "=== $(date) 结束 ==="
ls -l /mnt/e/DSH-Fuxi/t36-usb-msd4.img 2>/dev/null
