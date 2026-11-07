#!/bin/bash
# Rebuild the firmware (DEBUG, so the Tools menu has the Advanced Logger) and wrap the
# t36-bl2 volume with it, producing a t36-based test image.
set -uo pipefail
LOG=/root/fwlog-image.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) ==="

U=/root/build/uefi-fuxi
TREE=/root/build/unixnu
DEV=/root/build/fuxi

echo "--- 构建固件（DEBUG）---"
cd "$TREE" || exit 1
./unixnu build firmware -D "$DEV" --uefi "$U" --target DEBUG 2>&1 | tail -6
FD=$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
ls -l "$FD"

echo "--- 用新固件 + t36-bl2 卷做底镜像 ---"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-with-fd.sh > /root/fuxi/pwf.sh
bash /root/fuxi/pwf.sh "$U/BootShim/BootShim.bin" "$FD" /root/fuxi/t36-bl2/vol.img t36-fdlog 2>&1 | tail -3

echo "--- 以它为 loader 做 USB 测试镜像 ---"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t36-usb.sh > /root/fuxi/m36.sh
sed -i 's#/mnt/e/DSH-Fuxi/t32-usb.img#/mnt/e/DSH-Fuxi/t36-fdlog.img#g' /root/fuxi/m36.sh
bash /root/fuxi/m36.sh t36-usb-log3 2>&1 | tail -8

echo "=== $(date) 结束 ==="
ls -l /mnt/e/DSH-Fuxi/t36-usb-log3.img /mnt/e/DSH-Fuxi/t36-fdlog.img 2>/dev/null
