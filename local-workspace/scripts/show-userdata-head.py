#!/usr/bin/env python3
"""Look at the first MiB of the built userdata image: the docs say the windows
sit behind a manifest the kernel reads, so it must be there and well formed."""
import struct
from pathlib import Path

SPARSE = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/userdata/userdata-sparse.simg')
OUT = Path('/root/fuxi/userdata-head.bin')
CHUNK_RAW, CHUNK_FILL, CHUNK_DONT_CARE, CHUNK_CRC32 = 0xCAC1, 0xCAC2, 0xCAC3, 0xCAC4

want = 2 << 20
buf = bytearray()
with SPARSE.open('rb') as f:
    magic, major, minor, fhs, chs, blk, total_blks, total_chunks, csum = struct.unpack('<IHHHHIIII', f.read(28))
    while len(buf) < want and total_chunks:
        ch = f.read(12)
        if len(ch) < 12:
            break
        ctype, _, csize, tsize = struct.unpack('<HHII', ch)
        total_chunks -= 1
        if ctype == CHUNK_RAW:
            buf += f.read(csize * blk)
        elif ctype == CHUNK_FILL:
            pattern = f.read(4)
            buf += pattern * (tsize // max(len(pattern), 1))
        elif ctype == CHUNK_DONT_CARE:
            buf += b'\0' * tsize
        elif ctype == CHUNK_CRC32:
            f.read(4)

head = bytes(buf[:want])
OUT.write_bytes(head)
print('取出前 %d 字节 -> %s' % (len(head), OUT))

print('\n=== 前 512 字节（hex + ascii）===')
for off in (0, 0x40, 0x80, 0x100, 0x200):
    row = head[off:off + 32]
    print('%06x  %-64s  %s' % (off, row.hex(), ''.join(chr(b) if 32 <= b < 127 else '.' for b in row)))

print('\n=== 找可辨认的字符串（前 64 KiB）===')
import re
for m in re.finditer(rb'[ -~]{6,}', head[:65536]):
    s = m.group().decode()
    print('  %06x  %s' % (m.start(), s[:70]))

print('\n=== 1 MiB 处（OS 窗口起点）===')
print('  偏移 0x100000 前 16 字节:', head[0x100000:0x100010].hex() if len(head) > 0x100000 else '（不够长）')
