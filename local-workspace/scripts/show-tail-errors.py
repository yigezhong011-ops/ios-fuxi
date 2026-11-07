#!/usr/bin/env python3
"""Show the errors near the end of the bootstrap log."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
hits = [i for i, l in enumerate(lines) if 'Error' in l or 'error:' in l]
print('错误行号:', hits[-8:])
for i in hits[-6:]:
    start = max(0, i - 10)
    print('---')
    for line in lines[start:i + 2]:
        print(line[:190])
