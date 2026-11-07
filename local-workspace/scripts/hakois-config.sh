#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== device.conf ==="
cat devices/fuxi/device.conf | head -25
echo
echo "=== fuxi.config ==="
cat devices/fuxi/configs/fuxi.config | head -20
echo
echo "=== defconfig ==="
cat devices/fuxi/configs/fuxi_defconfig
echo
echo "=== make fuxi_defconfig ==="
make fuxi_defconfig 2>&1 | tail -8
echo
echo "=== make config ==="
make config 2>&1 | tail -15
