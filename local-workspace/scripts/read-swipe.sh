#!/bin/bash
# Read-only: frame rate windows and key rows of the swipe test.
L=${1:-swipe-120}
[ -d /root/fuxi/hang/$L ] || { tr -d '\r' < /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py > /tmp/rsl.py; python3 -I /tmp/rsl.py --decode /mnt/e/DSH-Fuxi/logs/carve-$L/log.bin --out /root/fuxi/hang/$L; }
D=$(ls -d /root/fuxi/hang/$L/*/ | head -1); echo "$D"; grep -E 'uptime_s|slots_written' $D/header.txt
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py > /tmp/fbi.py
python3 -I /tmp/fbi.py $D 30 2>&1 | cut -c1-130 | head -24
echo "== coherence / clocks / fence, by slot"
grep -a -E '^#slot|^\[coherence\]|^\[clocks\]' $D/slots.txt | awk '/^#slot/{s=$3; next}{print s, $0}' | awk 'NR%40==1' | cut -c1-150 | tail -14
echo "== last rows"
grep -a -E '^\[(coherence|clocks|fence wait|scanout wait|gpu clients)\]' $D/latest.txt | cut -c1-170
echo "== cpu/thread rows"
grep -a -n -E '^\[(cpu|sched|load|busy|threads?)|^c[0-9] ' $D/latest.txt | cut -c1-170 | head -14
echo "== section names"; grep -a -o -E '^\[[a-z][a-z /_-]*\]' $D/latest.txt | sort -u | tr '\n' ' '; echo
