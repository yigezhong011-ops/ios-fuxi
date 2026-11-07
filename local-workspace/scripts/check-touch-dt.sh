#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt
echo "=== 设备树里的触摸节点 ==="
dtc -I dtb -O dts "$F" 2>/dev/null | grep -n -i -B2 -A18 'goodix\|touchscreen\|gt9916\|focaltech' | head -60
