#!/usr/bin/env python3
"""Verify the rebuilt payload and pack it into a boot image."""
import re
import struct
import subprocess
import zlib
from pathlib import Path

NEW = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/payload.img')
print('=== 载荷 %d 字节 ===' % NEW.stat().st_size)

a = subprocess.run(['mtype', '-i', str(NEW), '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'],
                   capture_output=True).stdout
cnt, _, tot = struct.unpack_from('<IIQ', a, 8)
off = 24
wp = 0
cl = None
for _ in range(cnt):
    nl, md, sz, cs = struct.unpack_from('<IIQQ', a, off)
    off += 24
    nm = a[off:off + nl - 1].decode()
    off += nl + (-nl % 8)
    pk = a[off:off + cs]
    off += cs + (-cs % 8)
    if nm.startswith('wallpaper/'):
        wp += 1
    if nm.endswith('.clients'):
        cl = zlib.decompress(pk).decode()
print('addon %d 字节, %d 条目, 壁纸条目 %d 个' % (len(a), cnt, wp))
print('clients = %r' % cl)

for f in ('kernel.macho', 'kernel.macho.adt', 'kernel.macho.trustcache', 'scratch-data.img'):
    r = subprocess.run(['mtype', '-i', str(NEW), '::/EFI/UniXNU/Payloads/' + f], capture_output=True)
    print('  %-28s %d B' % (f, len(r.stdout)))

t = subprocess.run(['mtype', '-i', str(NEW), '::/EFI/UniXNU/unixnu.toml'],
                   capture_output=True, text=True).stdout
args = re.search(r'args = "([^"]*)"', t).group(1).split()
print('参数 %d 个, 命令行 %d 字节' % (len(args), len(' '.join(args))))
for key in ('sheng-backlight=1', 'sheng-gpu-pause-us=100', 'sheng-fb-gpu=1', 'sheng-data-persist=2'):
    print('  %-26s %s' % (key, '在' if key in args else '不在'))
