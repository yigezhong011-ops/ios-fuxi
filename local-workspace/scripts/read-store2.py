#!/usr/bin/env python3
"""Read-only. Where the wallpaper store messages sit by disk offset, with context, to tell the newest boot from older ones. Usage: read-store2.py <lscan.txt>"""
import re, sys
from collections import Counter
b = open(sys.argv[1], 'rb').read()
marks = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
print('blocks', len(marks), 'offset range', marks[0].group(1).decode(), marks[-1].group(1).decode())
offs = [int(m.group(1)) for m in marks]
PATS = [b'Data store could not be created', b'unable to open database', b'SQLite error', b'PRBPosterExtensionDataStore', b'sheng-autoreset=', b'Darwin Kernel Version']
hits = {}
for p in PATS:
    i = 0; hits[p] = []
    while True:
        i = b.find(p, i)
        if i < 0: break
        # block index by binary search
        lo, hi = 0, len(marks) - 1
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if marks[mid].start() <= i: lo = mid
            else: hi = mid - 1
        hits[p].append((offs[lo], i))
        i += len(p)
for p in PATS:
    print(p.decode(), len(hits[p]), 'offsets (GB):', [round(o / 1e9, 2) for o, _ in sorted(set(hits[p]))][:40])
def ctx(i, n=420):
    s = b[max(0, i - n):i + n].decode('latin1')
    return ''.join(c if c == '\n' or 32 <= ord(c) < 127 else '.' for c in s)
for p in (b'Data store could not be created', b'unable to open database', b'SQLite error', b'PRBPosterExtensionDataStore'):
    print('=====', p.decode())
    hs = sorted(hits[p])
    for o, i in hs[-4:]:
        print('--- offset', o); print(ctx(i, 500))
c = Counter()
for p in (b'unable to open database', b'SQLite error'):
    for o, i in hits[p]:
        s = b[i:i + 150].split(b'\n')[0]
        c[re.sub(rb'[0-9A-F]{8}-[0-9A-F-]{27}|0x[0-9a-f]+|\d+', b'#', s).decode('latin1')] += 1
print('===== database messages'); [print(v, k[:150]) for k, v in c.most_common(15)]
