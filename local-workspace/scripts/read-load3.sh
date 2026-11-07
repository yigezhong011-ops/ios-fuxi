#!/bin/bash
# The small-core-free run against the control: load, frame windows, gap histogram.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-load.py > /tmp/rl.py
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gap-hist.py > /tmp/gh.py
sed -n 1,12p /tmp/gh.py
for L in swipe-load swipe-big2; do
  D=$(ls -d /root/fuxi/hang/$L/*/ | head -1)
  echo "======== $L $D"
  grep -E 'uptime_s' "$D/header.txt"
  python3 -I /tmp/rl.py "$D" | grep -v '^FUXI120 [a-qs-z]' | cut -c1-90
  python3 -I /tmp/fbi.py "$D" 30 2>&1 | sed -n '1,13p' | cut -c1-90
  S=$(python3 -I /tmp/fbi.py "$D" 30 2>&1 | sed -n '3p' | awk '{print $1}')
  python3 -I /tmp/gh.py "$D" "$S" 2>&1 | head -16 | cut -c1-90
  grep -a -E '^\[(coherence|clocks)\]' "$D/latest.txt" | cut -c1-110
done
grep -a -i -E 'panic|Assert' /root/fuxi/hang/swipe-big2/*/msgbuf.txt | head -5 | cut -c1-150
