#!/bin/bash
# Read-only: the kernel's crash records for Settings, and the Swift or runtime messages logged by it.
E=/mnt/e/DSH-Fuxi
D=$(python3 -I $E/unixnu-build/fuxi/scripts/read-sheng-log.py --decode $E/logs/carve-wallsettings/log.bin --out /root/fuxi/hang/wallsettings 2>&1 | tail -1 | cut -d: -f1)
echo "log $D"; sed -n 1p "$D/latest.txt" | cut -c1-80
ls "$D" | head -12
grep -a -E '^\[gpu clients\]' "$D/latest.txt" | cut -c1-500 | head -1
grep -a -n -E 'EXITCRASH|Preferences|EXC_|pc=|PC 0x' "$D/msgbuf.txt" | tail -20 | cut -c1-240
grep -a -c 'EXITCRASH' "$D/msgbuf.txt"
L=$E/logs/carve-wallsettings/lscan.txt
echo '== runtime messages'
grep -a -E 'Fatal error|Unexpectedly found nil|fatalError|Precondition failed|Swift/|BUG IN CLIENT|_dispatch_assert|Abort Cause|preconditionFailure|Could not cast|WallpaperSettings[A-Za-z.]*:.*[0-9]+:' "$L" | cut -c1-260 | sort | uniq -c | sort -rn | head -24
echo '== crash reports named'
grep -a -o -E '[A-Za-z_-]*Preferences[-A-Za-z0-9_.]*\.ips[A-Za-z.]*' "$L" | sort | uniq -c | sort -rn | head -6
