#!/usr/bin/env python3
"""Show the undefined symbols of the failing bootstrap link."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    text = z.read('kernel-bootstrap.log').decode('utf-8', 'replace')

lines = text.splitlines()
start = next((i for i, l in enumerate(lines) if 'Undefined symbols' in l), None)
if start is None:
    raise SystemExit('没找到 Undefined symbols')
for line in lines[start:start + 40]:
    print(line[:170])
