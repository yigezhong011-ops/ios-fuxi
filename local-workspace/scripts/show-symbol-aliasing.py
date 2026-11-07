#!/usr/bin/env python3
"""Show the lines around the failing generated header."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()

idx = next((i for i, l in enumerate(lines) if '_symbol_aliasing.h' in l), None)
print('命中行', idx, '共', len(lines))
start = max(0, idx - 12)
for line in lines[start:idx + 6]:
    print(line[:190])
