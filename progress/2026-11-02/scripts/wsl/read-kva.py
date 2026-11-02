#!/usr/bin/env python3
"""Hex dump of a Mach-O kernel at a virtual address. Usage: read-kva.py <kernel> <va> [bytes]"""
import struct
import sys

k = open(sys.argv[1], 'rb').read()
va, n = int(sys.argv[2], 16), int(sys.argv[3]) if len(sys.argv) > 3 else 64
ncmds, off = struct.unpack_from('<I', k, 16)[0], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        if vmaddr <= va < vmaddr + filesize:
            o = fileoff + va - vmaddr
            data = k[o:o + n]
            for i in range(0, len(data), 16):
                print(f'{va + i:x}: ' + ' '.join(f'{x:08x}' for x in struct.unpack_from(f'<{min(16, len(data) - i) // 4}I', data, i)))
            break
    off += size
