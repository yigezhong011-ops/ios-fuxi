#!/usr/bin/env python3
"""Dump and decode a HID report descriptor stored in the kernel (short items only).
Usage: dump-hid-desc.py <kernel.macho> <va> <length>"""
import struct
import sys

k = open(sys.argv[1], 'rb').read()
va, n = int(sys.argv[2], 16), int(sys.argv[3], 0)
ncmds = struct.unpack_from('<I', k, 16)[0]
off, segs = 32, []
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        segs.append((vmaddr, fileoff, filesize))
    off += size
o = next(fo + va - v for v, fo, fs in segs if v <= va < v + fs)
d = k[o:o + n]
print(d.hex(' '))
names = {(1, 0): 'Usage Page', (2, 0): 'Usage', (1, 1): 'Logical Min', (1, 2): 'Logical Max', (1, 7): 'Report Size',
         (1, 9): 'Report Count', (1, 8): 'Report ID', (0, 10): 'Collection', (0, 12): 'End Collection', (0, 8): 'Input',
         (2, 1): 'Usage Min', (2, 2): 'Usage Max', (0, 9): 'Output', (0, 11): 'Feature'}
i = 0
while i < len(d):
    b = d[i]
    size = (0, 1, 2, 4)[b & 3]
    typ, tag = (b >> 2) & 3, b >> 4
    val = int.from_bytes(d[i + 1:i + 1 + size], 'little') if size else 0
    print(f'  {i:3}: {names.get((typ, tag), f"t{typ} g{tag}"):14} {val:#x}')
    i += 1 + size
