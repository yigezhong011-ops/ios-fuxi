#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
D=$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc
echo "=== DXE.inc 90-125 行（看 USB 块是否被 if 包住）==="
awk 'NR>=88 && NR<=125 {printf "%4d| %s\n", NR, substr($0,1,130)}' "$D"
echo
echo "=== 各 USB 驱动的 depex / 依赖 ==="
for m in UsbInitDxe UsbConfigDxe UsbDeviceDxe UsbPwrCtrlDxe UsbfnDwc3Dxe UCDxe; do
  inf="$U/Binaries/nuwa/QcomPkg/Drivers/$m/$m.inf"
  printf '%-16s ' "$m"
  if [ -f "$inf" ]; then
    dep=$(awk '/^\[Depex\]/{f=1;next} f&&NF{printf "%s ", $0}' "$inf" | head -c 100)
    echo "depex: ${dep:-（无）}"
  else
    echo "没有 .inf"
  fi
done
