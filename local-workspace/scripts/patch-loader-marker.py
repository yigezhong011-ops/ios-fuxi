#!/usr/bin/env python3
"""Copy a fuxi boot image with a marker at the loader's very first instructions: a red band across the first 300 rows of the framebuffer ABL left scanning,
then the original path. A Mi-logo hang with the band is past ABL; without it, our code never ran. Temp boot only.
The band code sits in the FD's erased end (FF), reached from the entry's second word. Registers x9-x11 are free there: the stub sets what it uses.
Usage: patch-loader-marker.py <in.img> <out.img>"""
import gzip, struct, sys, zlib
src, dst = sys.argv[1:3]
d = open(src, 'rb').read()
ksize = struct.unpack_from('<I', d, 8)[0]
dec = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = bytearray(dec.decompress(d[4096:4096 + ksize]))
dtb = dec.unused_data
CAVE = 0x2F0000
assert body[0x38:0x3c] == b'ARMd'
assert struct.unpack_from('<I', body, 4)[0] == 0x1400000F, 'entry changed'
assert body[CAVE:CAVE + 0x100] == b'\xff' * 0x100, 'cave not erased'
assert body[0x3000c0 + 0x52:0x3000c0 + 0x5a].startswith(b'FAT32'), 'volume moved'
code = [
    0xD2B70009,  # movz x9, #0xb800, lsl #16      framebuffer 0xb8000000
    0xD28F1A0A,  # movz x10, #0x78d0
    0xF2A0004A,  # movk x10, #2, lsl #16          162000 words = 300 rows of 4320 bytes
    0xD2BFFFEB,  # movz x11, #0xffff, lsl #16     0xffff0000
    0xAA0B816B,  # orr x11, x11, x11, lsl #32
    0xF800852B,  # str x11, [x9], #8
    0xF100054A,  # subs x10, x10, #1
    0x54FFFFC1,  # b.ne -8
    0xD5033F9F,  # dsb sy
]
for i, w in enumerate(code):
    struct.pack_into('<I', body, CAVE + 4 * i, w)
at = CAVE + 4 * len(code)
struct.pack_into('<I', body, at, 0x14000000 | (((0x40 - at) >> 2) & 0x3FFFFFF))   # b 0x40, the original next step
struct.pack_into('<I', body, 4, 0x14000000 | ((CAVE - 4) >> 2))                   # entry: adr x1; b cave
kernel = gzip.compress(bytes(body), mtime=0) + dtb
hdr = b'ANDROID!' + struct.pack('<IIII', len(kernel), 1, struct.unpack_from('<I', d, 16)[0], 1580) + bytes(16) + struct.pack('<I', 3) + d[44:44 + 1536]
page = lambda b: b + bytes(-len(b) % 4096)
open(dst, 'wb').write(page(hdr) + page(kernel) + page(b'\0'))
print(dst, 'kernel section', hex(len(kernel)), 'band code at', hex(CAVE))
open('/tmp/marker-code.bin', 'wb').write(bytes(body[:8]) + bytes(body[CAVE:at + 4]))
