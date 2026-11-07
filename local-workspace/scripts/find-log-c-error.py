#!/usr/bin/env python3
"""Find the log.c compile error."""
import re
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()

pat = re.compile(r'log\.c:\d+')
hits = [l for l in lines if pat.search(l)]
print('log.c 相关行数', len(hits))
for line in hits[:25]:
    print('  ', line.strip()[:190])
