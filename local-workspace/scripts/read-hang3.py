#!/usr/bin/env python3
# Read-only: raw slots beyond those the last boot wrote: leftovers from earlier boots, with their time and X5/X6 rows.
import re, sys
b = open(sys.argv[1], 'rb').read()
BS = 4096; first = 33; size = 8; count = 1019
last = None; n = 0
for i in range(count):
    s = b[(first + i * size) * BS:(first + (i + 1) * size) * BS]
    if not s.strip(b'\0'):
        continue
    n += 1
    x5 = re.search(rb'(?m)^X5 [^\n]{0,60}', s); x6 = re.search(rb'(?m)^X6 [^\n]{0,60}', s)
    t = re.search(rb'uptime[=: ]+(\d+)', s)
    key = (x5.group()[:24] if x5 else b'', x6.group()[:24] if x6 else b'')
    if i < 3 or (i >= 84 and (key != last or i % 40 == 0)):
        print(i, 'head', s[:32].hex(), 't', t.group(1) if t else None, key)
    last = key
print('nonempty slots', n)
