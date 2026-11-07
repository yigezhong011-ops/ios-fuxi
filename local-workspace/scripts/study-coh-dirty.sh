#!/bin/bash
# Read-only: coherence rows from decoded logs, docs on the probe, history of the probe source, how the coh image was made.
echo "=== coherence rows"
for d in /root/build/fuxi/build/sheng-logs/untagged-*; do
  r=$(grep -ah 'coherence\]' "$d"/slots.txt "$d"/latest.txt 2>/dev/null | head -1 | cut -c1-110)
  [ -n "$r" ] && echo "$(basename "$d") $(stat -c %y "$d" | cut -c6-16) $r"
done | sort -k2,3
echo "=== docs"
cd /root/fuxi 2>/dev/null && git log -3 --format='%h %ad %s' --date=short -- fuxi2/package/GpuPowerProbe.cpp | cut -c1-120
grep -rnIiE 'write.?stream|coherence|io.?coheren|d0/64|sheng-gpu-coherent' /root/fuxi/docs /root/build/fuxi/docs /mnt/e/DSH-Fuxi/unixnu-build/fuxi/docs 2>/dev/null | cut -c1-200 | head -30
echo "=== notes (int-150 and later)"
grep -rlIE 'int-15[0-9]|d0/64' /root/fuxi --include='*.md' 2>/dev/null | head
echo "=== make-t50-coh.sh"
cut -c1-160 /mnt/e/DSH-Fuxi/dump/wsl/make-t50-coh.sh
