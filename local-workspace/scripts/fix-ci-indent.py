#!/usr/bin/env python3
"""Normalise the indentation of the inserted comment line."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')
bad = ' ' * 30 + '# gen-turnip-replay.py needs the host Turnip to capture a replay trace'
good = ' ' * 14 + '# gen-turnip-replay.py needs the host Turnip to capture a replay trace'
if bad in text:
    p.write_bytes(text.replace(bad, good, 1).encode('utf-8'))
    print('注释缩进已修正')
else:
    print('没找到需要修正的行')

lines = p.read_bytes().decode('utf-8').replace('\r\n', '\n').splitlines()
for i in range(192, 200):
    print('%4d|%s| %s' % (i + 1, ' ' * (len(lines[i]) - len(lines[i].lstrip())), lines[i].strip()[:100]))
