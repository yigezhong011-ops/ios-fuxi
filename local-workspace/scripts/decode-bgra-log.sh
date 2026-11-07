#!/bin/bash
# Decode the pulled log window and pull out the boot args, GPU rows and the last messages. Read-only.
B=/mnt/e/DSH-Fuxi/logs/twrp-bgra.bin; O=/root/fuxi/log-bgra
bash /mnt/e/DSH-Fuxi/dump/wsl/decode-log.sh "$B" "$O" | cut -c1-200 | head -30
D=$(ls -d "$O"/*/ | head -1); echo "dir $D"; ls -la "$D" | cut -c30-
echo "== boot-args flags"; tr -d '\0' < "$D/msgbuf.txt" | grep -a -m1 -o 'sheng-setup=0.*' | cut -c1-80
grep -a -c 'sheng-fb-bgra=1' "$D/msgbuf.txt"
echo "== panic / fault"; tr -d '\0' < "$D/msgbuf.txt" | grep -a -n -i -E 'panic\(|fault|hang|recover|stuck|timeout|Kernel trap' | cut -c1-200 | tail -25
echo "== gpu rows in latest"; grep -a -i -E 'gpu client text|\[gpu|native-metal|no linear|client|kgsl|ring|prime|fence' "$D/latest.txt" | cut -c1-200 | head -70
echo "== msgbuf metal"; tr -d '\0' < "$D/msgbuf.txt" | grep -a -i -E 'native-metal|metal2vulkan|Adreno|linear image|turnip|tu_' | cut -c1-200 | sort | uniq -c | sort -rn | head -40
echo "== msgbuf tail"; tr -d '\0' < "$D/msgbuf.txt" | tail -25 | cut -c1-200
