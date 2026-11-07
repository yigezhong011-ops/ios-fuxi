#!/bin/bash
# Who is denied the GPU client, and what the kernel says about slots. Read-only.
N=/mnt/e/DSH-Fuxi/logs/carve-ab2-t50-auto-gpu7tap/lscan.txt; C=/mnt/e/DSH-Fuxi/logs
echo '--- denied AGXDeviceUserClient, by process (whole capture)'
grep -a -o -E 'Sandbox: [A-Za-z0-9_.-]+\([0-9]+\) deny\([0-9]+\) iokit-open-user-client AGXDeviceUserClient' $N | sed -E 's/Sandbox: ([^(]+).*/\1/' | sort | uniq -c | sort -rn | head -40
echo '--- denied in the COM3 log of this run'
F=$(ls -t $C/com3-t50-auto-gpu7tap-*.log | head -1); echo $F
tr -d '\r' < $F | grep -a -o -E 'AGXDeviceUserClient failed MACF in process pid [0-9]+, [A-Za-z0-9_.-]+' | sed -E 's/.*, //' | sort | uniq -c | sort -rn
echo '--- slot and client lines'
tr -d '\r' < $F | grep -a -i -E 'gpu clients|slot|mount|e00002d5|client [0-9]|no free|NativeGpu|native-gpu' | cut -c1-130 | tail -25
echo '--- lines around device refused'
grep -a -n 'native-metal: device refused' $N | tail -3 | cut -c1-120
L=$(grep -a -n 'native-metal: device refused' $N | tail -1 | cut -d: -f1); sed -n "$((L-6)),$((L+3))p" $N | cut -c1-150
echo '--- poster processes present'
grep -a -o -E '[A-Za-z]*Poster[A-Za-z]*\([0-9]+\)' $N | sed -E 's/\(.*//' | sort | uniq -c | sort -rn | head -14
ls -la $C/com3-t50-auto-g7plug-* | tail -1 | cut -c24-
grep -a -c 'PRRenderer\|Metal' $N
