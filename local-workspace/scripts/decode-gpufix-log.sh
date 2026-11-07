#!/bin/bash
# Decode the gpu-fix log: GPU rows of the newest snapshot, client history, swap patch of upstream main. Read-only.
B=/mnt/e/DSH-Fuxi/logs/twrp-gpufix.bin; O=/root/fuxi/log-gpufix
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -2 | cut -c1-160
D=$(ls -d "$O"/*/ | head -1); L="$D/latest.txt"
grep -a -E 'uptime_s|slots_written|boot_id' "$D/header.txt"
echo "== GPU rows"
grep -a -E '^(X[0-9]|W[01] |S c|T |G |N |V |L |W |Wb|F |PR|P[0-9]|\[gpu|\[metal askers|\[fence wait|\[stall\] fence|\[bo pool|\[clocks)' "$L" | grep -a -v -E '^W[0-9]{2,} ' | cut -c1-220
echo "== distinct warnings over all slots"
grep -a -E '^(W|Wb|P[0-9]b?) ' "$D/slots.txt" | cut -c1-200 | sort | uniq -c | sort -rn | head -40
echo "== gpu clients / askers over time"
grep -a -E '^\[gpu clients\]|^\[metal askers\]' "$D/slots.txt" | cut -c1-200 | uniq | tail -24
echo "== client text / failures"
grep -a -n -i -E 'gpu client text|client text|device failed|refused|no free|slot' "$D/slots.txt" | grep -a -v -E 'slots|#slot|stall' | cut -c1-200 | sort -t: -k2 -u | head -30
echo "== crashes"
tr -d '\0' < "$D/msgbuf.txt" | grep -a -i -E 'WidgetRenderer|CollectionsPoster|PosterBoard|wallpaper|jetsam|Process .* exited|crash|EXC_' | cut -c1-200 | tail -30
echo "== prime"
grep -a -E '^PR ' "$D/slots.txt" | tail -2
