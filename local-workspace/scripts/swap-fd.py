#!/usr/bin/env python3
"""Rebuild a header-v3 fuxi boot image with its firmware volume replaced, keeping its BootShim, payload volume and appended DTB. Same layout as repack-with-vol.py.
The loader is 192 bytes of BootShim, then the 3145728 byte FD. Refuses anything but the known current FD. Usage: swap-fd.py <in img> <new fd> <out img>"""
import gzip
import hashlib
import struct
import sys
import zlib

SHIM, FD = 192, 3145728
h = lambda b: hashlib.sha256(b).hexdigest()[:16]
d = open(sys.argv[1], 'rb').read()
fd = open(sys.argv[2], 'rb').read()
ksize = struct.unpack_from('<I', d, 8)[0]
dec = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = dec.decompress(d[4096:4096 + ksize])
dtb = dec.unused_data
old = body[SHIM:SHIM + FD]
if h(old) != 'c421e9eb6cc2cd11' or len(fd) != FD:
    raise SystemExit(f'unexpected: old fd {h(old)}, new fd size {len(fd)}')
kernel = gzip.compress(body[:SHIM] + fd + body[SHIM + FD:], mtime=0) + dtb
hdr = b'ANDROID!' + struct.pack('<IIII', len(kernel), 1, struct.unpack_from('<I', d, 16)[0], 1580) + bytes(16) + struct.pack('<I', 3) + d[44:44 + 1536]
page = lambda b: b + bytes(-len(b) % 4096)
img = page(hdr) + page(kernel) + page(b'\0')
open(sys.argv[3], 'wb').write(img)
print('old fd', h(old), 'new fd', h(fd), 'image', h(img), len(img))
