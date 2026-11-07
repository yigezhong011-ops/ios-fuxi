#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== 我们的固件仓库里有这些吗 ==="
for f in Resources/MuPatches/Usb-Bus.patch \
         Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf; do
  if [ -e "$U/$f" ]; then echo "  有: $f"; else echo "  没有: $f"; fi
done
echo
echo "=== fuxi.dsc 里有没有 UsbPwrEnabler ==="
grep -n -i 'usb' "$U/Platforms/Xiaomi/fuxiPkg/fuxi.dsc" 2>/dev/null | head -10 | cut -c1-140
echo
echo "=== fuxi.fdf 里有没有 UsbPwrEnabler ==="
grep -n -i 'usb' "$U/Platforms/Xiaomi/fuxiPkg/fuxi.fdf" 2>/dev/null | head -10 | cut -c1-140
echo
echo "=== 这个树从哪来 ==="
git -C "$U" remote -v 2>/dev/null | head -2
git -C "$U" log --oneline -1 2>/dev/null | cut -c1-90
