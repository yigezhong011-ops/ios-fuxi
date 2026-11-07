#!/usr/bin/env python3
"""Compare the freshly built payload against t32's original."""
import re
import struct
import subprocess
import zlib
from pathlib import Path

E = Path('/mnt/e/DSH-Fuxi')
NEW = E / 'unixnu-build/unixnu/out/fuxi/payload/payload.img'
OLD = Path('/root/fuxi/t32/vol.img')
W = Path('/root/verify-wall')
W.mkdir(exist_ok=True)

for label, vol in (('原 t32 载荷', OLD), ('新载荷', NEW)):
    print('=== %s (%d 字节) ===' % (label, vol.stat().st_size))
    r = subprocess.run(['mdir', '-i', str(vol), '-/ ::/EFI/UniXNU/Payloads'], capture_output=True, text=True)
    for line in r.stdout.splitlines():
        if 'kernel' in line.lower() or 'scratch' in line.lower():
            print('  ', ' '.join(line.split()))
    print()

print('=== 新载荷的 addon ===')
r = subprocess.run(['mtype', '-i', str(NEW), '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'],
                   capture_output=True)
addon = r.stdout
count, _, tot = struct.unpack_from('<IIQ', addon, 8)
off = 24
clients = None
names = []
for _ in range(count):
    nlen, mode, size, csize = struct.unpack_from('<IIQQ', addon, off)
    off += 24
    nm = addon[off:off + nlen - 1].decode()
    off += nlen + (-nlen % 8)
    packed = addon[off:off + csize]
    off += csize + (-csize % 8)
    names.append((nm, size))
    if nm.endswith('.clients'):
        clients = zlib.decompress(packed).decode()
print('  %d 个条目, %d 字节' % (count, len(addon)))
for nm, size in names:
    if 'wallpaper' in nm or nm.endswith('.clients'):
        print('   %-46s %10d B' % (nm, size))
print('  clients = %r' % clients)

print('\n=== 新载荷的启动参数 ===')
r = subprocess.run(['mtype', '-i', str(NEW), '::/EFI/UniXNU/unixnu.toml'], capture_output=True, text=True)
args = re.search(r'args = "([^"]*)"', r.stdout).group(1).split()
print('  %d 个参数' % len(args))
for key in ('sheng-fb-gpu=0', 'sheng-backlight=1', 'sheng-data-persist=2', 'fuxi-touch-hw=7'):
    print('  %-24s %s' % (key, '在' if key in args else '不在'))

print('\n=== ADT 大小对比 ===')
for label, vol in (('原', OLD), ('新', NEW)):
    r = subprocess.run(['mtype', '-i', str(vol), '::/EFI/UniXNU/Payloads/kernel.macho.adt'],
                       capture_output=True)
    print('  %s: %d 字节' % (label, len(r.stdout)))
