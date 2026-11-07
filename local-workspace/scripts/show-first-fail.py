#!/usr/bin/env python3
"""Print context before the first failing target."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()

idx = next((i for i, l in enumerate(lines) if '*** [' in l), None)
print('首个失败目标在第', idx, '行')
if idx:
    for line in lines[max(0, idx - 30):idx + 3]:
        print(line[:190])
