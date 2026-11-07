#!/usr/bin/env python3
"""Find real compiler diagnostics in the 2.2M-line log."""
import re
import zipfile

PATTERN = re.compile(r'\.(?:c|cc|cpp|h|m|mm):\d+:\d+: (?:fatal )?error:')

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    lines = z.read('kernel-bootstrap.log').decode('utf-8', 'replace').splitlines()
print('行数', len(lines))
hits = [l for l in lines if PATTERN.search(l)]
print('诊断条数', len(hits))
seen = set()
for line in hits:
    key = line.strip()[:120]
    if key in seen:
        continue
    seen.add(key)
    print('  ', line.strip()[:190])
    if len(seen) > 12:
        break
