#!/usr/bin/env python3
"""Show the GPU workflow lines around the inserted step, with visible indentation."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
lines = p.read_bytes().decode('utf-8').replace('\r\n', '\n').splitlines()
for i in range(186, min(len(lines), 202)):
    line = lines[i]
    print('%4d|%s| %s' % (i + 1, ' ' * (len(line) - len(line.lstrip())), line.strip()[:110]))
