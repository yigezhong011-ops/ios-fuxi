#!/bin/bash
# Which boot does the pulled log belong to, and the full newest snapshot. Read-only.
D=$(ls -d /root/fuxi/log-bgra/*/ | head -1)
cat "$D/header.txt" | cut -c1-160
wc -c "$D"/*.txt
echo "== args in log"; tr -d '\0' < "$D/msgbuf.txt" | grep -a -m2 -E 'boot-args|Boot args' | cut -c1-120; grep -a -l 'sheng-fb-bgra' "$D"/*.txt
echo "== compare with the COM3 capture of gpu-fix"
L=$(ls -t /mnt/e/DSH-Fuxi/logs/gpu-fix-*.log | head -1)
for s in 'verify_swap failed' 'voicebankingd\[224\]' 'xid 3875'; do echo "$s: com3 $(grep -a -c "$s" "$L") twrp $(tr -d '\0' < "$D/msgbuf.txt" | grep -a -c "$s")"; done
echo "== latest.txt"
cut -c1-230 "$D/latest.txt"
