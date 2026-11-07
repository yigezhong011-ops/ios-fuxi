#!/bin/bash
# Read-only: the hang boot, from the high slots and from the decoded low window.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-high.py > /tmp/rh.py
python3 -I /tmp/rh.py /mnt/e/DSH-Fuxi/logs/carve-hanghigh/log.bin /tmp/last-slot.txt | cut -c1-170 | tail -n 50
echo "===== last high slot"; [ -f /tmp/last-slot.txt ] && head -n 34 /tmp/last-slot.txt | cut -c1-150
D=$(ls -d /root/fuxi/hang/hanghigh/*/ | head -1)
echo "===== low window $D"; grep -E 'boot_id|uptime_s|rounds|slots_written|state=' $D/header.txt | tr '\n' ' '; echo
grep -a -E '^#slot' $D/slots.txt | tail -3
awk '/^#slot/{s=$2" "$3; next} /^(X5|X6) /{print s" | "$0}' $D/slots.txt | cut -c1-100 | tail -24
echo "===== msgbuf tail"; tail -n 22 $D/msgbuf.txt | cut -c1-170
grep -a -c -i panic $D/msgbuf.txt
