#!/bin/bash
# Read-only: find the conform check's body by its calls, then print it.
cd /mnt/e/DSH-Fuxi/dump/wsl
D=/root/fuxi/sys-peek/dsc
tr -d '\r' < read-store-build.py > /tmp/rsb.py
python3 -I /tmp/rsb.py $D 1a8280000 a0000 2>/dev/null | grep -v '^{' > /tmp/pbs.txt
wc -l /tmp/pbs.txt
grep -n -E 'resourceValuesForKeys|getResourceValue|checkResourceIsReachable' /tmp/pbs.txt | cut -c1-100 | head -12
L=$(grep -n -E 'checkResourceIsReachable' /tmp/pbs.txt | head -1 | cut -d: -f1)
[ -n "$L" ] && sed -n "$((L-30)),$((L+110))p" /tmp/pbs.txt | cut -c1-96 | grep -E 'bl\s|ret|tbz|tbnz|cbz|cbnz|"|NS'
