#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== 让 mkxnuimg 用我们的 uefi-fuxi 作为 Mu-Silicium ==="
rm -f Mu-Silicium
ln -s /root/uefi-fuxi Mu-Silicium
ls -l Mu-Silicium

echo "=== 生成 XNUP payload（loader.efi + --usb）==="
python3 xnuloader/mkpayload.py -o out/usb-payload.bin loader.efi=xnuloader/loader.efi --usb
ls -lh out/usb-payload.bin

echo "=== 打 Android boot image ==="
FD_BASE=0xA7100000 FD_SIZE=0x300000 PAYLOAD_BASE=0xA8000000 \
UEFI_TARGET=fuxi \
UEFI_FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
python3 mkxnuimg.py -p out/usb-payload.bin -o out/fuxi-boot.img 2>&1 | tail -12
ls -lh out/fuxi-boot.img 2>/dev/null
