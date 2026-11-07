#!/bin/bash
set -uo pipefail
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
cd /root/UniXNU
python3 ./unixnu bootimg -D /root/UniXNU-fuxi --uefi /root/uefi-fuxi \
  --fd "$FD" \
  --dtb "$OUT/device-tree/hardware.dtb" \
  --ramdisk "$OUT/payload/payload.img" \
  -o "$OUT/boot/boot.img" > /root/unixnu-bootimg2.log 2>&1
echo "BOOTIMG_EXIT=$?"
tail -4 /root/unixnu-bootimg2.log
ls -lh "$OUT/boot/boot.img"
cp "$OUT/boot/boot.img" /mnt/e/DSH-Fuxi/unixnu-boot.img
ls -lh /mnt/e/DSH-Fuxi/unixnu-boot.img
