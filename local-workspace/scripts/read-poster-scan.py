#!/usr/bin/env python3
"""Group the scan rows. Read-only."""
import re
from collections import Counter
from pathlib import Path

rows = Path('/mnt/e/DSH-Fuxi/logs/poster-scan.txt').read_text(errors='replace').splitlines()
print('rows', len(rows))
c = Counter()
for r in rows:
    t = r.split(':', 2)[-1]
    c[re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}|\b\d{3,}\b', '#', t)[:330]] += 1
for k, v in c.most_common(45):
    print(v, k)
