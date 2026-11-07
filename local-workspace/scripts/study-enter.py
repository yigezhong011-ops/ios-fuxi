#!/usr/bin/env python3
# Read-only: locate DarwinEnter in the running image, and find which instruction 0xBB004084 is if the loader's page offset matches.
import struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-auto-hanghigh.img', 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + k])
print('body', hex(len(b)))
pat = struct.pack('<I', 0xD50B7E24)   # dc civac, x4
i = 0
while True:
    i = b.find(pat, i)
    if i < 0: break
    a = i & ~0xFFF
    ctx = struct.unpack_from('<6I', b, i - 8)
    print('dc civac x4 at', hex(i), 'in-page', hex(i & 0xFFF), [hex(x) for x in ctx])
    j = b.rfind(b'MZ', max(0, i - 0x400000), i)
    print('  nearest MZ', hex(j), 'offset from it', hex(i - j))
    open('/tmp/enter.bin', 'wb').write(b[i - 0x90:i + 0x60])
    i += 4
s = b.find(b'hand-off to the kernel')
print('string', hex(s))
