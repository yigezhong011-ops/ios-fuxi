#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
echo "=== Binaries/nuwa 里的 USB 驱动（native 副本）==="
ls "$U/Binaries/nuwa/QcomPkg/Drivers/" 2>/dev/null | grep -i usb | head -20
echo
echo "=== DXE.inc 里 USB 相关行的上下文 ==="
grep -n -B4 -A2 'UsbInitDxe\|UsbConfigDxe\|UsbPwrEnabler' "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" | cut -c1-130 | head -40
echo
echo "=== UsbPwrEnablerDxe 的文件 ==="
ls -l "$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/" 2>/dev/null
echo
echo "=== 它的 .inf 全文 ==="
cat "$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf" 2>/dev/null
echo
echo "=== depex 内容（依赖哪些 protocol）==="
xxd "$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.depex" 2>/dev/null | head -5
