#!/usr/bin/env python3
"""Inventory E: so the cleanup keeps what matters and removes what does not."""
from pathlib import Path

ROOT = Path('/mnt/e')


def size(p):
    total = 0
    files = 0
    try:
        if p.is_file():
            return p.stat().st_size, 1
        for q in p.rglob('*'):
            try:
                if q.is_file():
                    total += q.stat().st_size
                    files += 1
            except OSError:
                pass
    except OSError:
        pass
    return total, files


print('=== E: 顶层 ===')
entries = sorted(ROOT.iterdir(), key=lambda p: -size(p)[0])
for p in entries[:20]:
    s, n = size(p)
    print('  %-44s %8.1f MB  %6d 文件' % (p.name[:44], s / 1e6, n))

print()
print('=== E:\\DSH-Fuxi 一级 ===')
base = ROOT / 'DSH-Fuxi'
if base.exists():
    for p in sorted(base.iterdir(), key=lambda p: -size(p)[0])[:30]:
        s, n = size(p)
        print('  %-44s %8.1f MB  %6d 文件' % (p.name[:44], s / 1e6, n))
