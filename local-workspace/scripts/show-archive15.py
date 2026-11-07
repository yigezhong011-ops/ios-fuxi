#!/usr/bin/env python3
"""Show the head of archive-15's log to find why the firmware fetch failed."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    lines = z.read('archive-15-prepare-fuxi-gmu.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
for line in lines[:28]:
    print('   ', line[:170])
