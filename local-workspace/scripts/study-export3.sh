#!/bin/bash
# How long until the export settles? Read-only.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150
git -C $A show $P:CacheExport.h > /root/fuxi/cacheexport.txt
L=$(grep -n -E 'run\(' /root/fuxi/cacheexport.txt | head -1 | cut -d: -f1)
sed -n "$((L-6)),$((L+45))p" /root/fuxi/cacheexport.txt | cut -c1-170
grep -n -E 'kPeriod|Period|sleep\(' /root/fuxi/cacheexport.txt | cut -c1-150 | head
sed -n 84,95p /root/fuxi/oslog-src.txt | cut -c1-170
echo "== PosterBoard in the daily log"
L2=$(ls -d /root/fuxi/log-daily1/*/ | head -1)
tr -d '\000' < "$L2/msgbuf.txt" | grep -a -o -E '.{0,120}PosterBoard\[[0-9]+\] Corpse.{0,60}' | cut -c1-200 | head -8
tr -d '\000' < "$L2/msgbuf.txt" | grep -a -o -E 'PosterBoard\[[0-9]+\]' | sort -u | tr '\n' ' '; echo
tr -d '\000' < "$L2/msgbuf.txt" | grep -a -c 'Corpse allowed'
tr -d '\000' < "$L2/msgbuf.txt" | grep -a -o -E '[A-Za-z_.]+\[[0-9]+\] Corpse allowed' | sed -E 's/\[[0-9]+\].*//' | sort | uniq -c | sort -rn | head
grep -a -E '^(W|P[0-9]|Pb|Wb) ' "$L2/slots.txt" | grep -a -i -E 'poster|wallpaper' | cut -c1-160 | sort -u | head
