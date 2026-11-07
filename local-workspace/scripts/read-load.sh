#!/bin/bash
D=$(ls -d /root/fuxi/hang/swipe-load/*/ | head -1); echo "$D"; ls "$D"
sed -n 1p "$D/latest.txt" | cut -c1-200
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-load.py > /tmp/rl.py
python3 -I /tmp/rl.py "$D"
echo '=== last rounds, clocks'
grep -a '^\[clocks\]' "$D/latest.txt" | cut -c1-170 | tail -3
echo '=== frames'
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py; python3 -I /tmp/fbi.py "$D" 30 2>&1 | tail -12 | cut -c1-170
