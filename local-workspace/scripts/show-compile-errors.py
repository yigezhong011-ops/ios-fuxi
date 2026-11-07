#!/usr/bin/env python3
"""Show the actual compiler error lines."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
hits = [i for i, l in enumerate(lines) if 'error:' in l and 'warning' not in l]
print('error 行:', hits[:10])
for i in hits[:6]:
    print(lines[i][:200])
