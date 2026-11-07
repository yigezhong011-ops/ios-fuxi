#!/bin/bash
# Read-only: the conform check's body should compare resource values; look in PosterBoard's own text.
cd /mnt/e/DSH-Fuxi/dump/wsl
D=/root/fuxi/sys-peek/dsc
tr -d '\r' < read-store-build.py > /tmp/rsb.py
python3 -I /tmp/rsb.py $D 1ca830000 200000 2>/dev/null | grep -v '^{' > /tmp/pb.txt
wc -l /tmp/pb.txt
grep -n -E 'resourceValuesForKeys|getResourceValue|checkResourceIsReachable|setResourceValue' /tmp/pb.txt | cut -c1-100 | head -14
L=$(grep -n -E 'resourceValuesForKeys' /tmp/pb.txt | head -1 | cut -d: -f1)
[ -n "$L" ] && sed -n "$((L-50)),$((L+70))p" /tmp/pb.txt | cut -c1-100 | grep -E 'bl\s|ret$|tbz|tbnz|cbz|cbnz|"|NS'
