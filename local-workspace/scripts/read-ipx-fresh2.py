#!/usr/bin/env python3
"""Read-only: this boot's blocks in disk order, with the identity strings and the wall clock lines they hold, to tell one boot from another.
Usage: read-ipx-fresh2.py <new lscan> <old lscan>"""
import hashlib
import re
import sys


def blocks(path):
    cur, h, lines = None, None, []
    with open(path, 'rb') as f:
        for line in f:
            if line.startswith(b'#C '):
                if cur is not None:
                    yield cur, h.digest(), lines
                cur, h, lines = int(line.split()[1]), hashlib.sha1(), []
            elif cur is not None:
                h.update(line)
                lines.append(line)
    if cur is not None:
        yield cur, h.digest(), lines


old = {d for _, d, _ in blocks(sys.argv[2])}
rows = []
for off, d, lines in blocks(sys.argv[1]):
    if d in old:
        continue
    tags = []
    for line in lines:
        s = line.strip()
        if s in (b'iPhone10,3', b'iPhone15,2') or s.startswith((b'Model Identifier', b'Current Date', b'ProductType', b'ArtworkDeviceSubType', b'ArtworkDeviceProductDescription', b'productType', b'Device Information')) or b'contains' in s and b'iPad7' in s:
            tags.append(s[:70].decode('utf-8', 'replace'))
    rows.append((off, len(lines), tags))
rows.sort()
print('fresh', len(rows), 'first', rows[0][0], 'last', rows[-1][0])
prev = None
for off, n, tags in rows:
    if prev is not None and off - prev > 1 << 26:
        print('--- gap', (off - prev) >> 20, 'MiB')
    prev = off
    if tags:
        seen = []
        for t in tags:
            if t not in seen:
                seen.append(t)
        print(off, n, seen[:5])
