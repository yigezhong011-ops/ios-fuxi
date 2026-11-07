#!/usr/bin/env python3
"""Normalise the inserted comment's indentation with a regex, then show the block."""
import re
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')
text, n = re.subn(r'^[ \t]+(# gen-turnip-replay\.py needs the host Turnip)',
                  ' ' * 14 + r'\1', text, count=1, flags=re.M)
p.write_bytes(text.encode('utf-8'))
print('修正 %d 行' % n)

lines = p.read_bytes().decode('utf-8').splitlines()
for i in range(192, 200):
    print('%4d|%s| %s' % (i + 1, ' ' * (len(lines[i]) - len(lines[i].lstrip())), lines[i].strip()[:100]))
