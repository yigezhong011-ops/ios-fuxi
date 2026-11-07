#!/bin/bash
# Read-only: the migration function's calls and branches, and the store strings in both log captures.
cd /mnt/e/DSH-Fuxi/dump/wsl
python3 -I read-dsc-xref.py /mnt/e/DSH-Fuxi/dump/root-peek/dsc d 0x1ca91c14c 110 360 2>&1 | grep -v '^{' | cut -c1-115 | grep -E 'bl |tbz|tbnz|cbz|cbnz|b\.|"|ret|pacibsp|msgSend' | head -150
for L in /mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt /mnt/e/DSH-Fuxi/logs/carve-tonight/lscan.txt; do
  echo "== $L $(stat -c%s $L)"
  LC_ALL=C grep -a -E 'store version|[Dd]ata ?[Ss]tore|never ever' $L | cut -c1-200 | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/UUID/g; s/0x[0-9a-f]+/0x/g' | sort | uniq -c | sort -rn | head -26
done
