#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/l-usb3.bin
O=/root/fuxi/logs/usb3
mkdir -p /root/fuxi/logs
echo "=== 解码 ==="
python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -6
echo
echo "=== 解出的文件 ==="
D=$(ls -d "$O"/*/ 2>/dev/null | head -1)
echo "目录: $D"
ls -l "$D" 2>/dev/null | head -12
echo
echo "=== header ==="
cat "$D/header.txt" 2>/dev/null | head -12
