#!/usr/bin/env python3
"""The first written blocks of an Android sparse image (what lands at the start of the partition). Read-only.
Usage: simg-first-block.py <img.simg>"""
import struct
import sys

f = open(sys.argv[1], 'rb')
magic, _, _, fhdr, chdr, blk, total_blks, total_chunks, _ = struct.unpack('<IHHHHIIII', f.read(28))
f.seek(fhdr)
pos = 0
for i in range(6):
    ctype, _, csz, tot = struct.unpack('<HHII', f.read(chdr))
    data = f.read(tot - chdr)
    kind = {0xCAC1: 'raw', 0xCAC2: 'fill', 0xCAC3: 'dontcare', 0xCAC4: 'crc'}.get(ctype, hex(ctype))
    print(f'chunk {i}: {kind} at block {pos} x{csz}; first bytes {data[:48].hex()} {data[:48]!r}')
    pos += csz
