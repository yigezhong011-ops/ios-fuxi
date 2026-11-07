#!/bin/bash
set -uo pipefail
F="/mnt/e/DSH-Fuxi/ipsw16.5/iPhone10,3,iPhone10,6_16.5_20F66_Restore.ipsw"
if [ -f "$F" ]; then
  S=$(stat -c%s "$F")
  echo "已下载 $((S / 1048576)) MB / 5880 MB（$((S * 100 / 6165698198))%）"
else
  echo "尚未开始"
fi
ls -lh /mnt/e/DSH-Fuxi/ipsw16.5/ 2>/dev/null | tail -3
