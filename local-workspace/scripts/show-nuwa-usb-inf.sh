#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
D=$U/Binaries/nuwa/QcomPkg/Drivers
echo "=== UsbPwrCtrlDxe / UsbInitDxe / UsbConfigDxe 的 .inf ==="
for m in UsbPwrCtrlDxe UsbInitDxe UsbConfigDxe UsbDeviceDxe; do
  echo "--- $m ---"
  sed -n '1,60p' "$D/$m/$m.inf" 2>/dev/null | grep -vE '^\s*$' | head -22
  echo
done
