#!/usr/bin/env python3
"""Inflate carved gzip candidates as far as they go and report which are the sheng oslog. Read-only on inputs.
Usage: read-oslog-carve.py <carve dir> <output dir>"""
import re
import sys
import zlib
from pathlib import Path

src, out = Path(sys.argv[1]), Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
best = []
for f in sorted(src.glob('gz-*.bin')):
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    b = f.read_bytes()
    text = bytearray()
    try:
        for i in range(0, len(b), 1 << 16):
            text += d.decompress(b[i:i + (1 << 16)])
            if d.eof:
                break
    except zlib.error:
        pass
    m = re.match(rb'# sheng oslog pass (\d+)', text)
    if m:
        best.append((int(m[1]), len(text), d.eof, f.name))
        (out / (f.stem + '.txt')).write_bytes(text)
best.sort()
print('pass bytes complete file')
for row in best:
    print(row)
