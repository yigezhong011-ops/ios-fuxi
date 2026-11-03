#!/usr/bin/env python3
"""Rebuild a header-v3 fuxi boot image with its payload volume replaced, keeping that image's own loader and appended DTB.
pack-payload.sh always uses t32's loader; this keeps e.g. t36's. Usage: repack-with-vol.py <orig.img> <vol.img> <out.img>"""
import gzip
import struct
import sys
import zlib

orig, vol_path, out = sys.argv[1:4]
d = open(orig, 'rb').read()
ksize = struct.unpack_from('<I', d, 8)[0]
dec = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = dec.decompress(d[4096:4096 + ksize])
dtb = dec.unused_data
vol = open(vol_path, 'rb').read()
base = body.find(vol[:3])  # the boot sector jump; confirm with the volume label below
base = next(b for b in range(0, 8 << 20, 2)
            if body[b + 0x52:b + 0x5a].startswith(b'FAT32') and body[b + 0x1fe:b + 0x200] == b'\x55\xaa')
assert len(body) - base == len(vol), (len(body) - base, len(vol))
kernel = gzip.compress(body[:base] + vol, mtime=0) + dtb
ramdisk = b'\0'
hdr = b'ANDROID!' + struct.pack('<IIII', len(kernel), len(ramdisk), struct.unpack_from('<I', d, 16)[0], 1580) \
    + bytes(16) + struct.pack('<I', 3) + d[44:44 + 1536]
page = lambda b: b + bytes(-len(b) % 4096)
open(out, 'wb').write(page(hdr) + page(kernel) + page(ramdisk))
print(f'{out}: loader {base} + volume {len(vol)}, dtb {len(dtb)}, kernel section {len(kernel)}')
