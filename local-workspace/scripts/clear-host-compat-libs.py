#!/usr/bin/env python3
"""HOST_COMPAT_LIBS asks for -lhostcompat, which the Linux toolchain does not
ship; xnu-host-cc already adds the libraries the SETUP tools need at link time."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
if "'HOST_COMPAT_LIBS'" in t:
    print('已经设置')
else:
    old = "            'HOST_COMPAT_CFLAGS': '',"
    new = ("            'HOST_COMPAT_CFLAGS': '',\n"
           "            'HOST_COMPAT_LIBS': '',")
    if old not in t:
        raise SystemExit('找不到 HOST_COMPAT_CFLAGS 行')
    p.write_text(t.replace(old, new, 1))
    print('已清空 HOST_COMPAT_LIBS')

for line in p.read_text().splitlines():
    if 'HOST_COMPAT' in line:
        print('  ' + line.strip()[:110])
