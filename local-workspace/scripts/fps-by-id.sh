#!/bin/bash
# Read-only: re-analysis of the existing controlled A/B log.
ls -d /root/fuxi/cad-ab/*/ 2>/dev/null
D=$(ls -d /root/fuxi/cad-ab/*/ | head -1)
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fps-by-id.py "$D" 30
echo "=== rows mentioning offers"
grep -a -m3 -E 'offers|offer ' "$D/latest.txt" | cut -c1-200
grep -a -m2 -E '^W[0-9]+ ' "$D/slots.txt" | cut -c1-160
echo "=== old analysis for comparison"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fps-phases.py "$D" 30
