#!/bin/bash
# Which GPU and Metal errors the last daily-style boot logged, most frequent first.
L=/mnt/e/DSH-Fuxi/logs
for f in com3-attach-001614.log com3-t50-auto-gpu7tap-001001.log; do
  echo "=== $f $(wc -l < $L/$f) lines"
  tr -d '\r' < "$L/$f" | grep -a -i -E 'metal|adreno|agx|iogpu|fence|gpu|shader|m2v|vulkan|turnip' \
    | sed -E 's/0x[0-9a-f]+/0xN/g; s/[0-9]+/N/g' | cut -c1-110 | sort | uniq -c | sort -rn | head -45
done
echo "=== last FUXI120S"
tr -d '\r' < $L/com3-attach-094314.log | grep -a FUXI120S | tail -3
echo "=== plugin images anywhere"
find /mnt/e/DSH-Fuxi -maxdepth 2 -name '*plugin*.img' 2>/dev/null
ls -d /root/fuxi/*plugin* /root/fuxi/gpu-new* /root/fuxi/m2v-try 2>/dev/null
echo "=== pins"
cd /root/fuxi 2>/dev/null && ls
for r in /root/fuxi/ref-*; do [ -d "$r/.git" ] && echo "$r $(git -C "$r" log -1 --format='%h %ad' --date=short)"; done
