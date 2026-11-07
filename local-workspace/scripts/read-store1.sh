#!/bin/bash
# Read-only: counts of the wallpaper store's messages in the log blocks, in disk order, and the header format.
F=/mnt/e/DSH-Fuxi/logs/carve-storefix/lscan.txt
ls -l /mnt/e/DSH-Fuxi/logs/carve-*/lscan.txt 2>/dev/null | cut -c20-
head -c 400 "$F" | cut -c1-200; echo
for p in 'Data store could not be created' 'failed to setup database' 'generalErrorDomain Code=0' 'F_SETPROTECTIONCLASS' 'NSFileProtection' 'PRBPosterExtensionDataStore' 'buildDataStoreForURL' 'Unable to create data store' 'SQLite error' 'unable to open database' 'protection class'; do
  printf '%-36s %s\n' "$p" "$(grep -a -c -F "$p" "$F")"
done
grep -a -n -F 'Data store could not be created' "$F" | tail -5 | cut -c1-200
grep -a -n '^#' "$F" | tail -3 | cut -c1-120
D=$(python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode /mnt/e/DSH-Fuxi/logs/carve-storefix/log.bin --out /root/fuxi/hang/storefix 2>&1 | tail -1 | cut -d: -f1); echo "$D"
sed -n 1p "$D/latest.txt" | cut -c1-120
grep -a -i -E 'protection|PosterBoard|posterboard|store' "$D/msgbuf.txt" | tail -25 | cut -c1-190
