#!/bin/bash
# Read-only: the REBOOT test's own log: when launchd asked for reboot(2), and what came after.
D=$(ls -d /root/fuxi/hang/peer-boot1/*/ | head -1); cd "$D"
cat header.txt | cut -c1-80
L=$(grep -a -n 'Will be calling reboot' msgbuf.txt | head -1 | cut -d: -f1); echo "line $L of $(wc -l < msgbuf.txt)"
sed -n "$((L-14)),$((L+12))p" msgbuf.txt | cut -c1-170
echo "== last msgbuf"; tail -n 10 msgbuf.txt | cut -c1-170
echo "== shutdown words"; grep -a -n -E 'launchd.*(shutdown|reboot|Userspace)|userspace reboot|SIGTERM|Shutting down|shutdown' msgbuf.txt | cut -c1-150 | head -14
echo "== slot times near the end"; grep -a -E '^#slot' slots.txt | tail -6
grep -a -n -E '^\[reset\]' -A2 latest.txt | cut -c1-140
