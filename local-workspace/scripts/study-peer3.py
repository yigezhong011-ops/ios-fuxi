#!/usr/bin/env python3
# Read-only: identity and Data-related settings of the peer image against ours.
import re, sys
PAT = re.compile(rb'[ -~]{0,160}(?:sheng-data|sheng-setup|data-persist|data-reset|fuxi-backlight|unit-scale|ProductType|iPad[0-9]+,[0-9]+|iPhone1[0-9],[0-9]+|sheng-gpu-clients|subtype)[ -~]{0,240}')
for p in sys.argv[1:]:
    b = open(p, 'rb').read()
    print('==', p)
    seen = set()
    for m in PAT.finditer(b):
        s = m.group()
        if s in seen: continue
        seen.add(s)
        print(hex(m.start()), s[:400].decode('ascii', 'replace'))
        if len(seen) >= 45: break
