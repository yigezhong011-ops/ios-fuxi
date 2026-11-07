#!/bin/bash
# Read-only: what the long try wrote: its low window header, and high slots with small numbers.
D=$(ls -dt /root/fuxi/hang/hh-133808/*/ 2>/dev/null | head -1); [ -z "$D" ] && { echo "not decoded yet"; exit 0; }
echo "$D"; grep -E 'uptime_s|rounds|slots_written|state=' $D/header.txt | tr '\n' ' '; echo
grep -a -E '^#slot' $D/slots.txt | tail -2
grep -a -c FUXI120 $D/msgbuf.txt
awk '/^#slot/{s=$2" "$3; next} /^X5 /{print s" | "$0}' $D/slots.txt | cut -c1-90 | tail -3
grep -a -E '^\[coherence\]' $D/latest.txt | cut -c1-120
tail -n 6 $D/msgbuf.txt | cut -c1-150
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-high2.py > /tmp/rh2.py
python3 -I /tmp/rh2.py /mnt/e/DSH-Fuxi/logs/carve-hh-133808/log.bin /tmp/ls3.txt | cut -c1-120 | head -14
