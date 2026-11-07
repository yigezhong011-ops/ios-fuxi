#!/usr/bin/env python3
"""List kernel symbols whose name mentions exec, to find the right disassembly target."""
import struct

path = '/mnt/e/DSH-Fuxi/ci/kinject/kernel.development.fuxi.unstripped'
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
hits = []
for i in range(nsyms):
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, symoff + i * 16)
    if strx == 0:
        continue
    end = data.index(b'\0', stroff + strx)
    name = data[stroff + strx:end].decode(errors='replace')
    if 'exec_mach_imgact' in name or name in ('_execve', 'exec_handle_cs'):
        hits.append((name, ntype, value))
for name, ntype, value in sorted(hits, key=lambda t: t[2]):
    print('%-40s type=%#04x value=%#x' % (name, ntype, value))
print('total', len(hits))
