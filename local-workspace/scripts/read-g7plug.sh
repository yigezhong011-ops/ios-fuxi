#!/bin/bash
# Shader refusals in the capture. lscan mixes boots, so compare with the earlier capture and show where hits fall in disk order.
N=/mnt/e/DSH-Fuxi/logs/carve-g7plug/lscan.txt; O=/mnt/e/DSH-Fuxi/logs/carve-iphonex-second/lscan.txt
P='pro24MainFragment|lightsMeshFragment|NeedsInput|FunctionConstant'
ls -la $N | cut -c24-; wc -l $O $N | head -2
for f in $O $N; do
  echo "== $(basename $(dirname $f))"
  for k in pro24MainFragment lightsMeshFragment NeedsInput FunctionConstant; do echo "$k $(grep -a -c "$k" $f)"; done
done
echo '--- line format'; sed -n '1000,1003p' $N | cut -c1-140
echo '--- hit position, percent of lines'
T=$(wc -l < $N); grep -a -n -E "$P" $N | cut -d: -f1 | awk -v t=$T '{b=int($1*20/t); c[b]++} END{for(i=0;i<20;i++) printf "%d%%:%d ",i*5,c[i]+0; print ""}'
echo '--- last hits'; grep -a -E "$P" $N | tail -8 | cut -c1-240
echo '--- refusal kinds'; grep -a -o -E 'NeedsInput\([A-Za-z]+\)|Unsupported\([A-Za-z]+\)' $N | sort | uniq -c | sort -rn | head -12
echo '--- posters'; for k in KaleidoscopePoster PridePosterExtension HelloPosterExtension; do echo "$k $(grep -a -c "$k" $N)"; done
