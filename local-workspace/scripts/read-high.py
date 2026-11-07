#!/usr/bin/env python3
# Read-only: slots from index 500 of a pulled log window: which ones this boot wrote (t, X5, X6 and Z rows), and the last slot's text.
import re, sys
b = open(sys.argv[1], 'rb').read()
BS = 4096; first = 33 + 500 * 8; size = 8
slots = []
i = 0
while (first + (i + 1) * size) * BS <= len(b):
    s = b[(first + i * size) * BS:(first + (i + 1) * size) * BS]
    h = re.match(rb'#slot (\d+) t=(\d+)s', s)
    if h:
        slots.append((i, int(h[1]), int(h[2]), s))
    i += 1
print('slots with data from 500:', len(slots))
print('num/t head:', [(n, t) for _, n, t, _ in slots[:6]], 'tail:', [(n, t) for _, n, t, _ in slots[-6:]])
last = None
for idx, n, t, s in slots:
    x = [re.search(rb'(?m)^%s [^\n]{0,70}' % k, s) for k in (b'X5', b'X6')]
    z = re.search(rb'(?m)^Z\d[^\n]{0,40}', s)
    key = tuple(m.group()[:44] if m else b'' for m in x)
    if key != last:
        print(f'#{n} t={t}', key[0].decode('ascii', 'replace'), '|', key[1].decode('ascii', 'replace'), '|', z.group().decode('ascii', 'replace') if z else '')
    last = key
if slots:
    open(sys.argv[2], 'wb').write(slots[-1][3].rstrip(b'\0'))
    print('last slot written to', sys.argv[2], len(slots[-1][3].rstrip(b'\0')), 'bytes')
