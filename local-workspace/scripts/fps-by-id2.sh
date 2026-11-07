#!/bin/bash
# Read-only: does each image carry the 120 Hz blob; true frame rate of today's boots on 120 Hz images.
E=/mnt/e/DSH-Fuxi
for i in t50-mine-gpu-fix t50-auto-120clock-p t50-auto-coh; do
  echo "$i FUXI120 strings: $(grep -a -c 'FUXI120' $E/$i.img)"
done
L=/root/build/fuxi/build/sheng-logs
for n in "untagged-64a63a760 120clock" "untagged-a94af048 120fix_touched_coherence_off" "untagged-45d8d0fd load" "untagged-20611b89 coh_failed_boot"; do
  set -- $n
  echo "=================== $2"
  grep -a -m1 '^\[coherence\]' $L/$1/slots.txt | cut -c1-70
  python3 -I $E/dump/wsl/fps-by-id.py $L/$1 30 2>&1 | sed '/slot timeline/,$d' | head -16
done
echo "=== daily fix A/B serial evidence"; ls -t $E/logs/com3-*fix* 2>/dev/null | head -3
