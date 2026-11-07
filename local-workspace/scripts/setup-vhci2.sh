#!/bin/bash
set -uo pipefail
K=$(uname -r)
T=/root/wslkernel
M="/lib/modules/$K"
echo "=== 补齐 modules.order / modules.builtin ==="
for f in modules.order modules.builtin modules.builtin.modinfo modules.builtin.alias.bin; do
  [ -f "$T/$f" ] && cp -f "$T/$f" "$M/$f" && echo "copied $f"
done
depmod -a "$K" 2>&1 | tail -3
echo "=== 先 insmod usbip-core，再 vhci-hcd ==="
insmod "$M/kernel/drivers/usb/usbip/usbip-core.ko" 2>&1 && echo usbip_core_ok
insmod "$M/kernel/drivers/usb/usbip/vhci-hcd.ko" 2>&1 && echo vhci_ok
lsmod | grep -E 'vhci|usbip' || echo "still not loaded"
echo "=== dmesg 末尾 ==="
dmesg | tail -6
ls /sys/devices/platform/vhci_hcd 2>/dev/null | head -5 || true
echo VHCI_V2_DONE
