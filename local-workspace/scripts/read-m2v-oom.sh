#!/bin/bash
# Read only: where the native-metal refusals sit in the capture, their exact values, and the code that makes them.
N=/mnt/e/DSH-Fuxi/logs/carve-$1/lscan.txt; A=/root/fuxi/src-adrenometal
grep -a -n 'native-metal: ' $N | grep -v 'binary archive' > /tmp/nm.txt; wc -l < /tmp/nm.txt
echo '--- per 1M lines: all, OOM, device'
python3 -I - <<'EOF'
b = {}
for line in open('/tmp/nm.txt', encoding='utf-8', errors='replace'):
    n, _, t = line.partition(':'); k = int(n) // 1000000
    r = b.setdefault(k, [0, 0, 0]); r[0] += 1; r[1] += 'OutOfMemory' in t; r[2] += 'device refused' in t
for k in sorted(b): print(k, b[k])
EOF
echo '--- exact kinds in the last 1.5M lines'
T=$(wc -l < $N); awk -F: -v m=$((T-1500000)) '$1>m' /tmp/nm.txt | cut -d: -f2- | sed -E 's/0x[0-9a-f]+/N/g' | cut -c1-120 | sort | uniq -c | sort -rn | head -25
echo '--- device refused codes, all'
grep -a -o 'device refused: device: Vulkan([^)]*))' /tmp/nm.txt | sort | uniq -c
echo '--- around the last OOM'
L=$(grep -a 'OutOfMemory' /tmp/nm.txt | tail -1 | cut -d: -f1); echo "line $L of $T"; sed -n "$((L-8)),$((L+4))p" $N | cut -c1-150
echo '--- source of the limit'
git -C $A grep -n -E 'OutOfMemory|out of memory|heap budget|maxMemoryAllocationCount|ERROR_TOO_MANY' ce63701 -- '*.mm' '*.h' '*.cpp' | cut -c1-170 | head -14
ls /root/fuxi/ | grep -iE 'src-|^up-|mesa|turnip|metal2' | head -20
