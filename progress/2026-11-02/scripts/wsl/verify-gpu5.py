#!/usr/bin/env python3
"""Verify t32-gpu5 before booting it: same header, same args, only the client list changed."""
import re
import struct
import subprocess
import zlib
from pathlib import Path

E = Path('/mnt/e/DSH-Fuxi')
W = Path('/root/verify-gpu5')
W.mkdir(exist_ok=True)


def payload(image):
    d = Path(image).read_bytes()
    hsize = struct.unpack_from('<I', d, 20)[0]
    ksize = struct.unpack_from('<I', d, 8)[0]
    start = (hsize + 4095) // 4096 * 4096
    un = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = un.decompress(d[start:start + ksize])
    fat = None
    for m in range(0, 8 << 20, 2):
        bs = body[m:m + 512]
        if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
            fat = m
            break
    total = struct.unpack_from('<I', body, fat + 32)[0]
    return d, body[fat:fat + total * 512]


for name in ('t32-bl-daily.img', 't32-gpu5.img'):
    d, p = payload(E / name)
    (W / (name + '.payload')).write_bytes(p)
    print('%-22s 镜像 %10d B  payload %d B' % (name, len(d), len(p)))

print()
for name in ('t32-bl-daily.img', 't32-gpu5.img'):
    r = subprocess.run(['mtype', '-i', str(W / (name + '.payload')),
                        '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'], capture_output=True)
    addon = r.stdout
    count, _, tot = struct.unpack_from('<IIQ', addon, 8)
    off, names = 24, []
    clients = None
    for _ in range(count):
        nlen, mode, size, csize = struct.unpack_from('<IIQQ', addon, off)
        off += 24
        nm = addon[off:off + nlen - 1].decode()
        off += nlen + (-nlen % 8)
        packed = addon[off:off + csize]
        off += csize + (-csize % 8)
        names.append(nm)
        if nm.endswith('.clients'):
            clients = zlib.decompress(packed).decode()
    print('%s: addon %d B, %d 条目' % (name, len(addon), count))
    print('   clients = %r' % clients)
    print('   移除的条目 =', [n for n in ('daemons/com.apple.bluetoothd.plist',) if n not in names] or '无')

print()
for name in ('t32-bl-daily.img', 't32-gpu5.img'):
    r = subprocess.run(['mtype', '-i', str(W / (name + '.payload')), '::/EFI/UniXNU/unixnu.toml'],
                       capture_output=True, text=True)
    args = re.search(r'args = "([^"]*)"', r.stdout).group(1)
    print('%-22s args %d 个, sha-ish 长度 %d' % (name, len(args.split()), len(args)))
