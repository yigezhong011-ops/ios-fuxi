#!/usr/bin/env python3
# Read-only: compare a good try's window with the following odd try's, slot by slot from slot 500. Unchanged slots were not written by the odd boot.
import re, sys, hashlib
a = open(sys.argv[1], 'rb').read(); b = open(sys.argv[2], 'rb').read()
BS = 4096; first = 33 + 500 * 8; size = 8
changed = []
for i in range(519):
    x = a[(first + i * size) * BS:(first + (i + 1) * size) * BS]; y = b[(first + i * size) * BS:(first + (i + 1) * size) * BS]
    if x != y:
        changed.append(i)
print('high slots changed by the odd boot:', len(changed), (changed[0], changed[-1]) if changed else '')
last = None
for i in changed:
    s = b[(first + i * size) * BS:(first + (i + 1) * size) * BS]
    h = re.match(rb'#slot (\d+) t=(\d+)s', s)
    x = [re.search(rb'(?m)^%s [^\n]{0,60}' % k, s) for k in (b'X5', b'X6')]
    key = tuple(m.group()[:44] if m else b'' for m in x)
    if key != last:
        print(f'idx {i}', h.group().decode() if h else None, key[0].decode('ascii', 'replace'), '|', key[1].decode('ascii', 'replace'))
    last = key
if changed:
    s = b[(first + changed[-1] * size) * BS:(first + (changed[-1] + 1) * size) * BS].rstrip(b'\0')
    print('=== last changed slot'); print(s[:1400].decode('ascii', 'replace'))
for name, d in (('good', a), ('odd', b)):
    h = d[:160]
    print(name, 'magic', h[:8], 'sha of first 2MB', hashlib.sha256(d[:2 << 20]).hexdigest()[:12])
    t = re.search(rb'\[ *(\d+\.\d+)\]', d[BS:33 * BS][::-1][:0] or b'')
