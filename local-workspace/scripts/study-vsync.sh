#!/bin/bash
# Read-only: where NativeLegacyDisplay's vsync tick comes from, what upstream says about it, our rows over time.
cd /root/fuxi
grep -o -E '.{0,500}sheng-vsync.{0,600}' up-latest/docs/.vitepress/device-records/sheng.toml | cut -c1-1200
echo "== source hits"
timeout 100 grep -rIl -E 'native_legacy_vsync_observed|sheng-vsync' fuxi2 ux-device fork-device ref-sad-fuxi up-latest/patches 2>/dev/null | grep -v -E '\.git/|docs/' | head -12
P=$(timeout 100 grep -rIl 'native_legacy_vsync_observed' ux-device fuxi2 2>/dev/null | grep -v -E 'LegacyDisplayProbe|\.git/' | head -1); echo "P=$P"
if [ -n "$P" ]; then grep -n -E 'vsync|Vsync|VSync' "$P" | cut -c1-190 | head -50; fi
echo "== rows"
L=/root/fuxi/wall1/log/untagged-2c15ceb80/slots.txt
grep -a -n 'vsync hz' $L | sed -n '1p;$p' | cut -c1-200
grep -a -c 'vsync hz' $L
grep -a 'vsync hz' $L | awk '{for(i=1;i<=NF;i++) if($i ~ /^sent=/) print $i}' | sort | uniq -c | sort -rn | head -4
grep -a -E 'swaps|frames.*waited|came a refresh|fb_|present' /root/fuxi/wall1/log/untagged-2c15ceb80/latest.txt | cut -c1-200 | head -10
