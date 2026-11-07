#!/usr/bin/env python3
"""What is inside the 12 MB GPU addon? Look for firmware markers (zap, gmu, sqe),
embedded Mach-O images, or a container index."""
import re
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-payload-parts/gpu-addon.ngpu')
d = p.read_bytes()
print('大小 %d 字节' % len(d))
print('魔数:', d[:8])

# 容器头
import struct
magic = d[:8]
if magic == b'NGPUADD2':
    ver, count = struct.unpack_from('<II', d, 8)
    print('  version=%d entries=%d' % (ver, count))
    print('  头 64 字节:', d[:64].hex())
    for i in range(min(count, 6)):
        off = 16 + i * 32
        if off + 32 > len(d):
            break
        print('  entry %d: %s' % (i, d[off:off + 32].hex()))

print()
print('=== 固件特征串 ===')
for kw in (b'zap', b'gmu', b'sqe', b'ZAP', b'GMU', b'a740', b'A740', b'gen70200',
           b'fuxi', b'sheng', b'MACHO', b'MH\x00'):
    at = [m.start() for m in re.finditer(re.escape(kw), d)][:3]
    if at:
        print('  %-10s 出现 %d 处，前几个偏移: %s' % (kw.decode(), len(at), at))

print()
print('=== 可读字符串（前 20 个，长度>=8）===')
n = 0
for m in re.finditer(rb'[ -~]{8,}', d):
    s = m.group().decode()
    print('  %08x  %s' % (m.start(), s[:80]))
    n += 1
    if n >= 20:
        break
