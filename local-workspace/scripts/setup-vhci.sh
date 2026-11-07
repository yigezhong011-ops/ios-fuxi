#!/bin/bash
set -uo pipefail
K=$(uname -r)
echo "kernel: $K"
D="/lib/modules/$K/kernel/drivers/usb/usbip"
mkdir -p "$D"
cp -v /root/wslkernel/drivers/usb/usbip/*.ko "$D" 2>&1 | tail -3
depmod -a "$K"
echo "--- modprobe ---"
modprobe vhci-hcd 2>&1 && echo MODPROBE_OK
lsmod | grep -E 'vhci|usbip' || echo "no module loaded"
ls /sys/devices/platform/vhci_hcd 2>/dev/null | head -3 || true
echo VHCI_SETUP_DONE
