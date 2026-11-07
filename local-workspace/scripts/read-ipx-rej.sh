#!/bin/bash
# Read-only: the display's rejection rows on the iPhone X boot, and the identity this boot's own log blocks show.
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/build/sheng-logs/untagged-447e254a
grep -a -n -E 'rej|reason|surf|accepted|validate|\[swap timeline\]|^SW|^RJ' $D/latest.txt | cut -c1-190 | head -24
grep -n -E '"rej |rej=|rej %|native_legacy_rej_' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package/*.c /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package/*.cpp | grep -v 'volatile\|LegacyDisplayProbe' | cut -c1-200 | head -12
echo ==== fresh
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-ipx-fresh.py /mnt/e/DSH-Fuxi/logs/carve-iphonex-second/lscan.txt /mnt/e/DSH-Fuxi/logs/carve-iphonex-first/lscan.txt | grep -v -E 'rdar|StatusBar|statusBar|Reuse|gesture' | cut -c1-170 | head -34
