#!/bin/bash
# Read-only: print the function around 0x1ca870964 that calls resourceValuesForKeys.
cd /mnt/e/DSH-Fuxi/dump/wsl
D=/root/fuxi/sys-peek/dsc
if [ ! -s /tmp/pb.txt ]; then
  tr -d '\r' < read-store-build.py > /tmp/rsb.py
  python3 -I /tmp/rsb.py $D 1ca830000 200000 2>/dev/null | grep -v '^{' > /tmp/pb.txt
fi
wc -l /tmp/pb.txt
L=$(grep -n '^0x1ca870964' /tmp/pb.txt | cut -d: -f1)
echo "line $L"
[ -z "$L" ] && exit 0
# Function start: last ret or pacibsp before the call.
S=$(sed -n "$((L-200)),${L}p" /tmp/pb.txt | grep -n -E 'pacibsp' | tail -1 | cut -d: -f1)
S=$((L-200+S-1))
echo "start line $S"
sed -n "$S,$((S+170))p" /tmp/pb.txt | cut -c1-110 | grep -E '^0x[0-9a-f]+ .*(bl\s|ret|retab|tbz|tbnz|cbz|cbnz|b\.|\sb\s|"|NS|pacibsp)' | head -90
