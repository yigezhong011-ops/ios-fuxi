#!/bin/bash
# Split the capture at boot markers and count poster activity per stretch, newest stretches last. Read-only.
N=/mnt/e/DSH-Fuxi/logs/carve-plugrant/lscan.txt; C=/mnt/e/DSH-Fuxi/logs
grep -a -n -E 'Doing boot task|mount-phase-1|PBFDataRefreshState.*Refresh Strategy|Successfully spawned (Kaleidoscope|Pride|Hello)Poster|Successfully spawned (PridePosterExtension|HelloPosterExtension)|deny\(1\) iokit-open-user-client AGXDeviceUserClient|PBFPosterSnapshotter cleanup is running for .*(Kaleidoscope|Pride|Hello)|Refresh Strategy was' $N > /tmp/pr4.txt
wc -l < /tmp/pr4.txt
python3 -I - /tmp/pr4.txt <<'EOF'
import re, sys
rows = []
for line in open(sys.argv[1], encoding='utf-8', errors='replace'):
    n, _, t = line.partition(':')
    rows.append((int(n), t))
seg = []; cur = None
for n, t in rows:
    if 'Doing boot task' in t or 'mount-phase-1' in t:
        if cur is None or n - cur['start'] > 20000:
            cur = {'start': n, 'spawnK': 0, 'spawnP': 0, 'spawnH': 0, 'denyAGX': 0, 'denyK': 0, 'snapK': 0, 'snapP': 0, 'snapH': 0, 'refreshNo': 0, 'refresh': 0}; seg.append(cur)
        continue
    if cur is None:
        continue
    if 'spawned KaleidoscopePoster' in t: cur['spawnK'] += 1
    if 'spawned PridePoster' in t: cur['spawnP'] += 1
    if 'spawned HelloPoster' in t: cur['spawnH'] += 1
    if 'deny(1) iokit-open' in t:
        cur['denyAGX'] += 1
        if 'KaleidoscopePoster' in t: cur['denyK'] += 1
    if 'cleanup is running' in t:
        cur['snapK'] += 'Kaleidoscope' in t; cur['snapP'] += 'Pride' in t; cur['snapH'] += 'Hello' in t
    if 'Refresh Strategy was' in t:
        cur['refresh'] += 1; cur['refreshNo'] += 'RefreshNo' in t
print('stretches', len(seg))
for s in seg[-12:]:
    print(s)
EOF
for f in com3-t50-auto-g7plugrant-105313.log com3-t50-auto-g7plug-102732.log com3-t50-auto-gpu7tap-103336.log; do
  echo "$f Kaleidoscope lines $(tr -d '\r' < $C/$f | grep -a -c -i 'kaleidoscope')  MACF $(tr -d '\r' < $C/$f | grep -a -c 'failed MACF')"
done
tr -d '\r' < $C/com3-t50-auto-g7plugrant-105313.log | grep -a -i 'kaleidoscope' | cut -c1-150 | head -8
