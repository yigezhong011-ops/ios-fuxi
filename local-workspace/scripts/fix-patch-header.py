#!/usr/bin/env python3
"""Rewrite the diff header so the patch applies with -p1 against the XNU tree."""
from pathlib import Path

p = Path('/root/fuxi/fork-device/patches/xnu/portable-iig-local-methods.patch')
lines = p.read_text().splitlines()
out = []
for line in lines:
    if line.startswith('--- '):
        out.append('--- a/iokit/Kernel/IOUserServer.cpp')
    elif line.startswith('+++ '):
        out.append('+++ b/iokit/Kernel/IOUserServer.cpp')
    else:
        out.append(line)
p.write_text('\n'.join(out) + '\n')
print('\n'.join(out[:6]))
