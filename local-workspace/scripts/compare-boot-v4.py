#!/usr/bin/env python3
"""Parse boot image headers v4 correctly and compare."""
import struct

files = [
    ('作者/进度条正常', '/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/boot-gpu3-cpus6.img'),
    ('我们/只有点', '/mnt/e/DSH-Fuxi/fuxi-metal-arrearm.img'),
    ('我们/静默', '/mnt/e/DSH-Fuxi/fuxi-metal-quiet.img'),
]

for label, path in files:
    d = open(path, 'rb').read(2400)
    assert d[:8] == b'ANDROID!', path
    ksize, rsize, osver, hsize = struct.unpack('<IIII', d[8:24])
    reserved = struct.unpack('<4I', d[24:40])
    hver = struct.unpack('<I', d[40:44])[0]
    cmd = d[44:44 + 1536].split(b'\0')[0].decode(errors='replace')
    print('=== %s ===' % label)
    print('  kernel_size=%d ramdisk_size=%d os_version=%#x header_size=%d header_version=%d'
          % (ksize, rsize, osver, hsize, hver))
    print('  reserved=%s' % (reserved,))
    print('  cmdline: %s' % (cmd[:200] + ('…' if len(cmd) > 200 else '')))
    print('  cmdline 长度 %d' % len(cmd))
    print()
