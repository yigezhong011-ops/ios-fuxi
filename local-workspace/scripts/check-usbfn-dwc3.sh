#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
echo "=== UsbfnDwc3Dxe 有没有在任何 fdf/inc/dsc 里被加载 ==="
grep -rn 'UsbfnDwc3Dxe' "$U/Platforms" "$U/Silicon/Qualcomm/QcomPkg" 2>/dev/null | grep -v 'Binaries/nuwa/QcomPkg/Drivers/UsbfnDwc3Dxe/' | head -8 | cut -c1-150
echo
echo "=== fuxi 的 DXE.inc / APRIORI.inc 里所有 Usb 行 ==="
grep -n 'Usb\|UCDxe' "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" "$U/Platforms/Xiaomi/fuxiPkg/Include/APRIORI.inc" | cut -c1-130
echo
echo "=== UsbfnDwc3Dxe 的 depex ==="
xxd "$U/Binaries/nuwa/QcomPkg/Drivers/UsbfnDwc3Dxe/UsbfnDwc3Dxe.depex" 2>/dev/null | head -3
echo
echo "=== UsbDeviceDxe 里有没有引用 Usbfn 协议 ==="
strings -a "$U/Binaries/nuwa/QcomPkg/Drivers/UsbDeviceDxe/UsbDeviceDxe.efi" 2>/dev/null | grep -i 'usbfn\|dwc3\|QcomUsb' | head -8
