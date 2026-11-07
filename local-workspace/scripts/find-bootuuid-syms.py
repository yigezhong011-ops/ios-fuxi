#!/usr/bin/env python3
"""List every symbol in the kernel whose name mentions bootsession/boot_uuid."""
import struct
import sys

path = sys.argv[1]
data = open(path, 'rb').read()
magic, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', data[:32])
off = 32
symtab = None
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', data, off)
    if cmd == 0x2:
        symtab = struct.unpack_from('<IIII', data, off + 8)
    off += size
symoff, nsyms, stroff, strsize = symtab
hits = 0
for i in range(nsyms):
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, symoff + i * 16)
    if strx == 0:
        continue
    end = data.index(b'\0', stroff + strx)
    name = data[stroff + strx:end].decode(errors='replace')
    low = name.lower()
    if 'bootsession' in low or 'boot_uuid' in low or 'bootuuid' in low:
        print('%-48s type=%#04x sect=%d value=%#x' % (name, ntype, nsect, value))
        hits += 1
print('total hits:', hits, 'of', nsyms, 'symbols')
