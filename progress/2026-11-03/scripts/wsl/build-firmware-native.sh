#!/bin/bash
# Finish the native copy and build the firmware there: git and EDK2 need a real
# filesystem, the 9p mount breaks index.lock writes.
set -uo pipefail
LOG=/root/firmware-native.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

echo "--- rsync unixnu（续）---"
rsync -a --delete /mnt/e/DSH-Fuxi/unixnu-build/unixnu/ /root/build/unixnu/
echo "rsync exit=$?  $(du -sh /root/build/unixnu | cut -f1)"

echo "--- 确认固件目录的补丁还在 ---"
grep -n 'FUXI_USB_POWER' /root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc | head -3
grep -n 'UsbPwrEnablerDxe' /root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc | head -3

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu defconfig fuxi_full_defconfig -D /root/build/fuxi 2>&1 | tail -2
./unixnu build firmware -D /root/build/fuxi --uefi /root/build/uefi-fuxi --target DEBUG 2>&1 | tail -30
echo "=== $(date) 结束 exit=$? ==="
find /root/build/uefi-fuxi -name '*.fd' -newermt '-2 hours' 2>/dev/null | head -5
