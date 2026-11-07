#!/bin/bash
# Read only: the newest stretch of the capture, the lost context, the device refusals' neighbours, who sets SHENG_DIAG.
N=/mnt/e/DSH-Fuxi/logs/carve-m2vs-pride/lscan.txt; A=/root/fuxi/src-adrenometal; T=ce63701; U=/root/fuxi/up-latest
sed -n '25200000,$p' $N > /tmp/tail.txt
echo '--- boot markers and native-metal in the tail (line offset 25200000)'
grep -a -n -E 'native-metal|Doing boot task|mount-phase-1|Successfully spawned (Pride|Hello|Kaleidoscope|backboardd)|Pride.*(crash|exit|terminat|error|fail)' /tmp/tail.txt | grep -v 'no device answer' | sed -E 's/0x[0-9a-f]+/N/g' | cut -c1-150 | awk '{k=$0; sub(/^[0-9]+:/,"",k); if(k!=p) print; p=k}' | head -60
echo '--- around the lost context'
L=$(grep -a -n 'GPU context is lost' /tmp/tail.txt | cut -d: -f1); sed -n "$((L-14)),$((L+3))p" /tmp/tail.txt | cut -c1-150
echo '--- before the last device refusal'
L=$(grep -a -n 'device refused' /tmp/tail.txt | tail -1 | cut -d: -f1); sed -n "$((L-10)),$((L+2))p" /tmp/tail.txt | cut -c1-150
echo '--- SHENG_DIAG and context-lost sources'
git -C $A grep -n -E 'SHENG_DIAG|context is lost' $T -- '*.mm' '*.h' '*.cpp' '*.plist' | cut -c1-190 | head -10
git -C $U grep -n -E 'SHENG_DIAG' origin/feat/metal2vulkan-963f0e64 -- . 2>/dev/null | cut -c1-190 | head -10
git -C /mnt/e/DSH-Fuxi rev-parse 2>/dev/null; grep -l SHENG_DIAG /mnt/e/DSH-Fuxi/dump/wsl/*.sh /mnt/e/DSH-Fuxi/dump/wsl/*.py 2>/dev/null | head -5
echo '--- the plist env in the images'
for d in /root/fuxi/plug-t50-auto-m2vs; do strings -a $d/addon-merged.bin 2>/dev/null | grep -c SHENG_DIAG; done
sed -n 345,362p <(git -C $A show $T:NativeBridgeMetalFrontend.mm) | cut -c1-170
