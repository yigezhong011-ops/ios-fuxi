#!/usr/bin/env python3
"""Printable text around the earlier staged_system_apps hits. Read-only."""
import re
from pathlib import Path

for f in sorted(Path('/mnt/e/DSH-Fuxi/logs/staged-ctx').glob('ctx-*.bin')):
    b = f.read_bytes()
    print('==', f.name, len(b))
    for m in re.finditer(rb'staged_system_apps', b):
        print('  hit at', m.start())
        seg = b[max(0, m.start() - 400):m.end() + 400]
        print('   ', re.sub(rb'[^ -~]+', b' | ', seg).decode()[:900])
