#!/usr/bin/env python3
"""Find the real failure inside the full bootstrap log from the CI artifact."""
import re
import zipfile
from pathlib import Path

with zipfile.ZipFile('/root/ci-logs.zip') as z:
    text = z.read('kernel-bootstrap.log').decode('utf-8', 'replace')

lines = text.splitlines()
print('总行数:', len(lines))

pats = (': error:', 'Undefined symbols', 'ld: symbol', 'No such file', 'cannot find',
        '*** [')
hits = [i for i, l in enumerate(lines) if any(p in l for p in pats)]
print('命中行数:', len(hits))
for i in hits[:6] + hits[-6:]:
    print('%6d | %s' % (i, lines[i][:170]))
