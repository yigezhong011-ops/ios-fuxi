#!/usr/bin/env python3
"""Does the userdata OS image actually contain the APFS volume the kernel looks
for? Search for the UUID bytes of root_match_volume_uuid and for APFS signatures."""
import binascii
import struct
from pathlib import Path

TARGET = '04769D26-2CA0-4825-B443-E2E5F88300F2'
raw = bytes.fromhex(TARGET.replace('-', ''))

CANDIDATES = [
    ('/root/ux-out/fuxi/tree/../..', None),  # placeholder
]

paths = [
    Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw/21H461/044-76040-038.dmg'),
    Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/ipsw/21H461/044-76034-038.dmg'),
]

for p in paths:
    if not p.is_file():
        print('%s 不存在' % p)
        continue
    size = p.stat().st_size
    print('=== %s  (%.2f GB) ===' % (p.name, size / 1e9))
    found = []
    nx_magic = b'NXSB'
    apfs_vol = bytes.fromhex('41504653-0000-11AA-AA11-00306543ECAC'.replace('-', ''))
    with p.open('rb') as f:
        off = 0
        chunk = 8 << 20
        while True:
            data = f.read(chunk)
            if not data:
                break
            at = data.find(raw)
            if at >= 0:
                found.append(off + at)
            if not found and data.find(nx_magic) >= 0:
                found.append(('NXSB', off + data.find(nx_magic)))
            if len(found) > 3:
                break
            off += len(data)
    print('  目标 UUID 出现位置:', [x for x in found if isinstance(x, int)][:4] or '未找到')
    sigs = [x for x in found if isinstance(x, tuple)]
    print('  APFS 容器(NXSB):', sigs[:2] or '未找到')

print()
print('目标 UUID 原始字节:', binascii.hexlify(raw).decode())
