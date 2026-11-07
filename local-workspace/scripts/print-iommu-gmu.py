#!/usr/bin/env python3
"""Print fuxi's kgsl-iommu and gmu node blocks in full: the stream IDs and GMU
registers are what the Adreno driver must match."""
import re
from pathlib import Path

text = Path('/root/fuxi/fuxi.dts').read_text(errors='replace')
lines = text.splitlines()


def block(start_line):
    """Return the lines of the node starting at start_line (1-based)."""
    i = start_line - 1
    depth = 0
    out = []
    while i < len(lines):
        out.append(lines[i])
        depth += lines[i].count('{') - lines[i].count('}')
        if depth <= 0 and '{' in ''.join(out):
            break
        i += 1
    return out


for needle in ('kgsl-iommu@3da0000', 'gmu@3d69000'):
    idx = next((n + 1 for n, l in enumerate(lines) if needle in l), None)
    if not idx:
        print('没找到', needle)
        continue
    print('=== %s （从第 %d 行）===' % (needle, idx))
    for line in block(idx)[:45]:
        print('   ', line.strip()[:130])
    print()
