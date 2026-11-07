#!/usr/bin/env python3
"""Read the fuxi progress handoff document that appeared today."""
from pathlib import Path

for name in ('fuxi-进度交接.md', 'fuxi-进度交接.txt'):
    p = Path('/root/fuxi') / name
    if p.exists():
        text = p.read_text(errors='replace')
        print('===', name, len(text), '字节 ===')
        for line in text.splitlines()[:70]:
            print(line[:150])
        break
else:
    print('没找到交接文档')
    for p in Path('/root/fuxi').glob('*.md'):
        print('  ', p.name, p.stat().st_size)
