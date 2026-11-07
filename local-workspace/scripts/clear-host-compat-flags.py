#!/usr/bin/env python3
"""xnu-host-cc already force-includes unixnu-host-prefix.h; the SETUP Makefiles add
a second compat prefix header, and the two together break glibc's unistd.h. Clear
the duplicate for the Linux build."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
if "'HOST_COMPAT_CFLAGS'" in t:
    print('已经设置')
else:
    old = "            'HOST_CC': str(clt / 'bin/xnu-host-cc'),"
    new = ("            'HOST_CC': str(clt / 'bin/xnu-host-cc'),\n"
           "            # xnu-host-cc already force-includes the host prefix header;\n"
           "            # the SETUP Makefiles add hostcompat.h on top, and the two\n"
           "            # clash on glibc's unistd.h.\n"
           "            'HOST_COMPAT_CFLAGS': '',")
    if old not in t:
        raise SystemExit('找不到 HOST_CC 行')
    p.write_text(t.replace(old, new, 1))
    print('已设置 HOST_COMPAT_CFLAGS 为空')

for line in p.read_text().splitlines():
    if 'HOST_CC' in line or 'HOST_COMPAT' in line:
        print('  ' + line.strip()[:120])
