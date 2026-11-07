#!/bin/bash
# Which boot does this window hold, how far did it get, did the export start? Read-only.
B=/mnt/e/DSH-Fuxi/logs/twrp-loghang.bin; O=/root/fuxi/log-loghang
sha256sum $B /mnt/e/DSH-Fuxi/logs/twrp-daily1.bin | cut -c1-16
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -1 | cut -c1-160
L=$(ls -d $O/*/ | head -1)
grep -E '^(boot_id|uptime_s|slots_written|state|export_bytes|export_generation|crash_bytes|crash_generation)' "$L/header.txt" | tr '\n' ' '; echo
python3 /mnt/e/DSH-Fuxi/dump/wsl/read-diag.py loghang 2>&1 | grep -a -v -E 'waiting for matching|IOPropertyMatch|EmbeddedDeviceTypeRoot|^ *};?$|^}' | cut -c1-240 | head -70
echo "== latest"
grep -a -E '^X[0-9] |^\[coherence\]|^\[gpu clients\]|^\[metal askers\]|^G commit|^PR |^S c|^W[01] |^P[01] ' "$L/latest.txt" | cut -c1-220
echo "== markers"
grep -a -n -i -E 'K[0-9]+ |marker|69f|690' "$L/latest.txt" | cut -c1-140 | head -8
echo "== tail of msgbuf"
tr -d '\000' < "$L/msgbuf.txt" | tail -c 1800 | cut -c1-400
echo "== panic-like"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -c -E 'panic\(|Debugger|watchdog'
grep -a -E 'panic|watchdog' "$L/latest.txt" | cut -c1-200 | head -8
echo "== poster"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E 'PosterBoard\[[0-9]+\] Corpse' | sort | uniq -c | head
