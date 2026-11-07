#!/usr/bin/env python3
# Read-only: high slots written by the fast-log image, in window order; each run of slots is one boot (slot number restarts, t restarts).
import re, sys
b = open(sys.argv[1], 'rb').read()
BS = 4096; first = 33 + 500 * 8; size = 8
rows = []
for i in range(519):
    s = b[(first + i * size) * BS:(first + (i + 1) * size) * BS]
    h = re.match(rb'#slot (\d+) t=(\d+)s', s)
    if not h:
        rows.append((i, None, None, s)); continue
    rows.append((i, int(h[1]), int(h[2]), s))
print('window index, slot number, t for the first 320 and at every break:')
prev = None; run = 0
for i, n, t, s in rows[:520]:
    if n is None:
        if prev != 'empty': print(i, 'empty')
        prev = 'empty'; continue
    if prev is None or prev == 'empty' or n != prev + 1:
        print(i, 'slot', n, 't', t, 'run start')
    prev = n
last = None
for i, n, t, s in rows:
    if n is None or n > 400: continue
    x = [re.search(rb'(?m)^%s [^\n]{0,60}' % k, s) for k in (b'X5', b'X6')]
    key = tuple(m.group()[:40] if m else b'' for m in x)
    if key != last:
        print(f'idx {i} #{n} t={t}', key[0].decode('ascii', 'replace'), '|', key[1].decode('ascii', 'replace'))
    last = key
small = [r for r in rows if r[1] is not None and r[1] <= 400]
if small:
    print('last small slot', small[-1][:3])
    open(sys.argv[2], 'wb').write(small[-1][3].rstrip(b'\0'))
