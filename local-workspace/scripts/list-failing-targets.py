#!/usr/bin/env python3
"""List the failing targets and any distinctive error text."""
import re
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    text = z.read('kernel-bootstrap.log').decode('utf-8', 'replace')

targets = re.findall(r'\*\*\* \[([^\]]+)\] Error \d+', text)
print('失败目标数', len(targets))
from collections import Counter
for name, count in Counter(targets).most_common(15):
    print('  %-40s x%d' % (name[:40], count))

for pat in ('fatal error', 'error: expected', 'error: use of', 'error: no member', 'error: unknown'):
    found = [m.start() for m in re.finditer(pat, text)]
    if found:
        print('\n=== %s（%d 处）===' % (pat, len(found)))
        for pos in found[:3]:
            print('   ', text[max(0, pos - 120):pos + 120].replace('\n', ' ')[:230])
