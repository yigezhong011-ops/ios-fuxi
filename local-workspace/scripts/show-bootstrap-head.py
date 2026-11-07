#!/usr/bin/env python3
"""Show the beginning of the bootstrap log, where the failing patch is reported."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
for line in lines[:14]:
    print('   ', line[:175])
