#!/bin/bash
# Read only: how the DynamicSplit provider finds the island rectangle and the time's vertical centre.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/read-dsc-statusbar.py > /tmp/rds.py
python3 -I /tmp/rds.py /root/fuxi/sys-peek/dsc layout sensorAreaRect,sensorAreaSize,smallPillSize,topLeadingCenterOffset,effectiveTargetDisplayWidth > /tmp/rl.txt
sed -n '/DynamicSplit height/,$p' /tmp/rl.txt | awk '/^==/{n=0} {n++; if (n<=62) print}' | cut -c1-84
echo '== where setupInContainerView uses the leading centre'
python3 -I /tmp/rds.py /root/fuxi/sys-peek/dsc layout > /tmp/rl2.txt
grep -n -B14 -A3 'setLeadingCenterYConstraint:\]' /tmp/rl2.txt | grep -v 'da8a' | cut -c1-84 | head -40
grep -n -E 'topLeadingCenterOffset\]|sensorAreaRect\]' /tmp/rl2.txt | cut -c1-84 | head
