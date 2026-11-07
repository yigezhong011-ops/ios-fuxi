#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== nuwa 里的 USB 驱动 ==="
ls "$U/Binaries/nuwa/QcomPkg/Drivers/" 2>/dev/null | grep -i usb | head -20
echo
echo "=== 全树的 USB 设备模式驱动（.inf）==="
find "$U/Binaries" -iname '*usb*.inf' 2>/dev/null | head -15
echo
echo "=== NicobarPkg 的 UsbPwrEnablerDxe ==="
ls -l "$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/" 2>/dev/null
