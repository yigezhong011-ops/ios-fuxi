#!/bin/bash
# Read-only: good try vs odd try; then the odd try's low window (the daily boot it fell into).
G=hh-144246; O=hh-144517
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-hang-diff.py > /tmp/rhd.py
python3 -I /tmp/rhd.py /mnt/e/DSH-Fuxi/logs/carve-$G/log.bin /mnt/e/DSH-Fuxi/logs/carve-$O/log.bin | cut -c1-150 | head -70
D=$(ls -dt /root/fuxi/hang/$O/*/ 2>/dev/null | head -1); echo "== low window $D"; [ -n "$D" ] && grep -E 'uptime_s|rounds|slots_written' $D/header.txt | tr '\n' ' '; echo
