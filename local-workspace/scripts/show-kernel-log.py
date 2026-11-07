#!/usr/bin/env python3
"""Show the tail of the new kernel.log from the artifact."""
import zipfile

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    names = z.namelist()
    if 'kernel.log' not in names:
        print('没有 kernel.log，包内:', names)
        raise SystemExit
    lines = z.read('kernel.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
for line in lines[-30:]:
    print('   ', line[:175])
