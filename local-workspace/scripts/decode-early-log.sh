#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/l-early.bin
O=/root/fuxi/logs/early
rm -rf "$O"
python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -3
D=$(ls -d "$O"/*/ 2>/dev/null | head -1)
echo "目录: $D"
echo
echo "=== msgbuf 里 FUXI USB / USB 相关 ==="
tr -d '\0' < "$D/msgbuf.txt" | grep -aiE 'FUXI USB|qcom_usb|USB ph=|dwc3|vbus|DQE' | head -25 | cut -c1-190
echo
echo "=== msgbuf 覆盖的时间范围（首尾时间戳）==="
tr -d '\0' < "$D/msgbuf.txt" | grep -aoE '^\[ *[0-9]+\.[0-9]+\]' | head -2 | tr '\n' ' '
echo '...'
tr -d '\0' < "$D/msgbuf.txt" | grep -aoE '^\[ *[0-9]+\.[0-9]+\]' | tail -2 | tr '\n' ' '
echo
echo
echo "=== msgbuf 最开头 10 行 ==="
tr -d '\0' < "$D/msgbuf.txt" | head -10 | cut -c1-170
