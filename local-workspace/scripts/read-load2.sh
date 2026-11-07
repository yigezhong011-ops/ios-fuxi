#!/bin/bash
# Same frame and load tables for the control and the big-cores run.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-load.py > /tmp/rl.py
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gap-hist.py > /tmp/gh.py
for L in swipe-load swipe-big; do
  D=$(ls -d /root/fuxi/hang/$L/*/ | head -1)
  echo "======== $L $D"
  grep -E 'uptime_s|slots_written' "$D/header.txt"
  grep -a -c 'sched_recommended_cores' "$D/msgbuf.txt"
  python3 -I /tmp/rl.py "$D" | grep -v '^FUXI120'
  python3 -I /tmp/fbi.py "$D" 30 2>&1 | sed -n '1,14p' | cut -c1-100
  python3 -I /tmp/gh.py "$D" 2>&1 | head -16 | cut -c1-100
  grep -a -E '^\[(coherence|clocks)\]' "$D/latest.txt" | cut -c1-140
done
