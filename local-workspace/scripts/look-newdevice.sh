#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== new-device.sh 用法 ==="
sed -n '1,40p' common/new-device.sh 2>/dev/null
echo
echo "=== 我们手上的 fuxi 设备树 ==="
ls -l /mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt* 2>/dev/null
file /mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt 2>/dev/null
