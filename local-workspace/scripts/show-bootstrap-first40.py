#!/usr/bin/env python3
"""Which patch failed, and what came before it?"""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
for line in lines[:40]:
    print(line[:190])
