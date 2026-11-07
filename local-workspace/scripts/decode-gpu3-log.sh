#!/bin/bash
B=/mnt/e/DSH-Fuxi/logs/twrp-gpu3.bin; O=/root/fuxi/log-gpu3
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -1 | cut -c1-160
python3 - "$O" <<'EOF'
import re,sys
from pathlib import Path
d=next(Path(sys.argv[1]).glob('*/'))
s=[x for x in re.split(r'(?m)^(?=#slot )',(d/'slots.txt').read_text(errors='replace')) if x.startswith('#slot')]
last=s[-1]
def g(p,t=last):
    m=re.search(p,t,re.M); return m.group(1) if m else '-'
print('slots',len(s))
print('coherence:', g(r'^\[coherence\] (.*)$'))
print('G ctc    :', g(r'^(G commit-to-complete .*)$'))
print('clients  :', g(r'^\[gpu clients\] (.*)$')[:150])
# per-interval frame time
prev=None; rows=[]
for x in s:
    t=re.search(r'^#slot \d+ t=(\d+)s',x,re.M); m=re.search(r'^G commit-to-complete n=(\d+) total=(\d+)ms',x,re.M)
    if t and m:
        n,tot=int(m[1]),int(m[2])
        if prev and n>prev[0]: rows.append('%ss %dms/f'%(t[1],(tot-prev[1])/(n-prev[0])))
        prev=(n,tot)
print('per-interval:', rows[-18:])
# coherence over time
seen=[]
for x in s:
    c=re.search(r'^\[coherence\] H (d\d+/\d+ a\d+).* -> (\w+)',x,re.M); t=re.search(r't=(\d+)s',x)
    if c and (not seen or seen[-1][1:]!=(c[1],c[2])): seen.append((t.group(1),c[1],c[2]))
print('coherence timeline:', seen[:8])
print('PR       :', g(r'^(PR .*)$'))
print('fence    :', g(r'^(\[fence wait\] calls=\d+ timeouts=\d+ .*)$')[:120])
EOF
