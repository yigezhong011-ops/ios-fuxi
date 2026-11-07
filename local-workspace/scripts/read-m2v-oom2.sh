#!/bin/bash
# Read only: did this boot's Pride process get a device; who writes frames.trace; what a refused device means.
C=/mnt/e/DSH-Fuxi/logs; L=$C/com3-t50-auto-m2vs-163428.log; N=$C/carve-m2vs-pride/lscan.txt; A=/root/fuxi/src-adrenometal; T=ce63701
echo '--- COM3 words, this boot'
tr -d '\r' < $L | grep -a -E -i 'gpu client|client slot|slots|no free|AGXDeviceUserClient|failed MACF|adreno.*(fail|refus|full|deny)|kgsl.*(fail|full)|bo .*fail|out of|OOM|aperture' | sed -E 's/^\[?[ 0-9.]+\]? ?//; s/0x[0-9a-f]+/N/g; s/\b[0-9]+\b/N/g' | cut -c1-120 | sort | uniq -c | sort -rn | head -20
echo '--- Pride sandbox denials in COM3 and processes denied the GPU'
tr -d '\r' < $L | grep -a -E 'PridePoster' | sed -E 's/0x[0-9a-f]+/N/g; s/\b[0-9]+\b/N/g' | cut -c1-130 | sort | uniq -c | sort -rn | head -10
echo '--- frames.trace in the source'
git -C $A grep -n -E 'frames\.trace|traceWanted|diagOn\(\)' $T -- '*.mm' '*.h' | cut -c1-185 | head -16
echo '--- device refused in the source'
git -C $A grep -n -E 'device refused|refused\(|"device"' $T -- '*.mm' '*.h' | cut -c1-185 | head -10
echo '--- newest region: the refusals around each Pride start'
python3 -I - "$N" <<'EOF'
import re, sys, collections
last = None; L = []
with open(sys.argv[1], 'rb') as f:
    for i, b in enumerate(f):
        if i < 23800000: continue
        if b'Pride' in b or b'native-metal: device refused' in b or b'GPU context is lost' in b or b'no-copy buffer refused' in b or b'native-metal: texture (' in b:
            L.append((i + 1, b[:110].decode('utf-8', 'replace').strip()))
kinds = collections.Counter()
prev = None
for n, t in L:
    k = re.sub(r'0x[0-9a-f]+|\d+', 'N', t)[:70]
    if k != prev: print(n, t[:110]) if ('native-metal' in t or 'spawned' in t or 'lost' in t) else None
    prev = k
EOF
