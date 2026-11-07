#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/l-nosb.bin
O=/root/fuxi/logs/nosb
rm -rf "$O"
python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -3
D=$(ls -d "$O"/*/ 2>/dev/null | head -1)
echo "目录: $D"
echo
echo "=== msgbuf 里 FUXI USB / USB 相关 ==="
tr -d '\0' < "$D/msgbuf.txt" | grep -aiE 'FUXI USB|qcom_usb|USB ph=|dwc3|vbus' | head -20 | cut -c1-190
echo
echo "=== msgbuf 起止时间 ==="
tr -d '\0' < "$D/msgbuf.txt" | head -2 | cut -c1-120
tr -d '\0' < "$D/msgbuf.txt" | tail -2 | cut -c1-120
echo
echo "=== slots 里 USB ==="
grep -a -n -iE 'USB ph=|FUXI USB' "$D/slots.txt" 2>/dev/null | head -8 | cut -c1-160
