#!/usr/bin/env python3
"""Compare the boot image headers of the new GPU image and the known-good daily one."""
import struct
from pathlib import Path

for name in ('t32-bl-daily.img', 't32-gpu4.img'):
    p = Path('/mnt/e/DSH-Fuxi') / name
    d = p.read_bytes()[:4096]
    print('=== %s ===' % name)
    magic, ksize, rsize, osver, hsize = struct.unpack('<IIIII', d[:20])
    hver = struct.unpack('<I', d[40:44])[0]
    cmd = d[44:44 + 1536].split(b'\0')[0].decode(errors='replace')
    print('  magic %#x  kernel %d  ramdisk %d  os_version %#x  header_size %d  header_version %d'
          % (magic, ksize, rsize, osver, hsize, hver))
    print('  cmdline: %r' % cmd[:120])
    print()
