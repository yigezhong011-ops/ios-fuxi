#!/usr/bin/env python3
"""Print the C strings at the given virtual addresses of a Mach-O kernel.
Usage: kstr.py <kernel.macho> <va> [<va> ...]"""
import struct
import sys

k = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack_from('<I', k, 16)[0]
segs, off = [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        segs.append((vmaddr, fileoff, filesize))
    off += size
for a in sys.argv[2:]:
    va = int(a, 16)
    for vmaddr, fileoff, filesize in segs:
        if vmaddr <= va < vmaddr + filesize:
            o = fileoff + va - vmaddr
            print(f'{va:#x} {k[o:k.index(b"\0", o)].decode(errors="replace")!r}')
            break
    else:
        print(f'{va:#x} not mapped')
