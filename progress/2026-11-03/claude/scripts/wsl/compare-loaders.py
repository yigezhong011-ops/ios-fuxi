#!/usr/bin/env python3
"""Loader (UEFI before the FAT volume) and appended DTB of boot images: sizes and whether they match.
Usage: compare-loaders.py <img> <img> ..."""
import hashlib
import struct
import sys
import zlib

for p in sys.argv[1:]:
    d = open(p, 'rb').read()
    ks = struct.unpack_from('<I', d, 8)[0]
    dec = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = dec.decompress(d[4096:4096 + ks])
    base = next(b for b in range(0, 8 << 20, 2)
                if body[b + 0x52:b + 0x5a].startswith(b'FAT32') and body[b + 0x1fe:b + 0x200] == b'\x55\xaa')
    h = lambda b: hashlib.sha256(b).hexdigest()[:12]
    print(f'{p.split("/")[-1]:28s} loader {base} {h(body[:base])}  volume {len(body) - base}  dtb {len(dec.unused_data)} {h(dec.unused_data)}')
