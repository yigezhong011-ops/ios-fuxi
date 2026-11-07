#!/usr/bin/env python3
"""Show the failing part of the format-2 kernel bootstrap log."""
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
for line in lines:
    if any(k in line for k in ('error', 'Error', '***', 'symbol_aliasing', 'command not found', 'No such file')):
        print(line[:185])
