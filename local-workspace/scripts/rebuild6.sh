#!/bin/bash
set -uo pipefail
SHIM=/root/uefi-fuxi/BootShim/BootShim.S
if [ -f "$SHIM.orig" ]; then
  cp "$SHIM.orig" "$SHIM"
  echo "shim reverted"
fi
grep -n 'x19' "$SHIM" || echo "(shim clean)"
echo "=== 重建固件 ==="
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw6.log 2>&1
echo "FW6_EXIT=$?"
ls -lh /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
echo "=== 重建 boot.img ==="
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
python3 ./unixnu bootimg -D /root/UniXNU-fuxi --uefi /root/uefi-fuxi \
  --fd /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
  --dtb "$OUT/device-tree/hardware.dtb" \
  --ramdisk "$OUT/payload/payload.img" \
  -o "$OUT/boot/boot.img" > /root/bootimg6.log 2>&1
echo "BOOTIMG_EXIT=$?"
tail -2 /root/bootimg6.log
cp "$OUT/boot/boot.img" /mnt/e/DSH-Fuxi/unixnu-boot.img
ls -lh /mnt/e/DSH-Fuxi/unixnu-boot.img
