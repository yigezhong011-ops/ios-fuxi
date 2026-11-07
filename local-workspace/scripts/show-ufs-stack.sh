#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== FUXI_UFS_STACK 决定加载什么 ==="
grep -rn 'FUXI_UFS_STACK' "$U/Platforms/Xiaomi/fuxiPkg/" 2>/dev/null | head -10 | cut -c1-150
echo
echo "=== UsbPwrEnablerDxe 在哪里被引用 ==="
grep -rn 'UsbPwrEnablerDxe' "$U" --include='*.dsc' --include='*.fdf' --include='*.inc' 2>/dev/null | head -10 | cut -c1-150
echo
echo "=== Usb-Bus.patch 是干什么的 ==="
head -25 "$U/Resources/MuPatches/Usb-Bus.patch" 2>/dev/null | cut -c1-140
