#!/usr/bin/env python3
"""Locate the trust-cache bundle the board pins."""
import hashlib
from pathlib import Path

WANT = '7416ca4f8377146626bb284e2133c76bee6cb4e3ee0af5d648b186235a7323a7'
SECOND = '8900d6a93d7a59ce1a872a5c081e559f4240a218f97e12d44d22dda46644d68f'
found = []
for root in (Path('/mnt/e/DSH-Fuxi'), Path('/root/fuxi')):
    for p in root.rglob('*'):
        if not p.is_file():
            continue
        try:
            if p.stat().st_size > 200_000 or p.stat().st_size < 20_000:
                continue
            data = p.read_bytes()
        except OSError:
            continue
        digest = hashlib.sha256(data).hexdigest()
        if digest == WANT:
            found.append(('PIN', p, len(data), digest))
        elif digest == SECOND:
            found.append(('SECOND', p, len(data), digest))
        elif 'trustcache' in p.name.lower() or 'trust-cache' in p.name.lower() or 'trust_cache' in p.name.lower():
            found.append(('name', p, len(data), digest[:16]))

for tag, p, size, digest in found[:12]:
    print('%-7s %-64s %8d %s' % (tag, str(p), size, digest))
print('总计', len(found))
