#!/bin/bash
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq usbutils python3-pip 2>&1 | tail -2
python3 -m pip install --quiet --break-system-packages pyusb 2>&1 | tail -3
python3 -c 'import usb.core, usb.util; print("pyusb ok", usb.core.__version__ if hasattr(usb.core,"__version__") else "")'
which usbip 2>/dev/null || echo "usbip: 未安装（需要放行 USB 时才用）"
lsusb 2>/dev/null | head -5
echo PREP_USB_DONE
