#!/usr/bin/env python3
"""Show the undefined symbols of the current kernel link."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    lines = z.read('kernel.log').decode('utf-8', 'replace').splitlines()
start = next((i for i, l in enumerate(lines) if 'Undefined symbols' in l), None)
if start is None:
    print('没有 Undefined symbols，尾部：')
    for line in lines[-24:]:
        print('   ', line[:170])
else:
    for line in lines[start:start + 26]:
        print(line[:175])
