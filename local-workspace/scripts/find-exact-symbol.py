#!/usr/bin/env python3
"""Print the exact nlist entry for _bootsessionuuid_string and its section."""
import struct
import sys

path = '/mnt/e/DSH-Fuxi/ci/kinject/kernel.development.fuxi.unstripped'
data = open(path, 'rb').read()
magic, cputype, cpusub, filetype, ncmds, sizeofcmds, flags, _ = struct.unpack('<8I', data[:32])
off = 32
symtab = None
segments = []
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', data, off)
    if cmd == 0x2:
        symtab = struct.unpack_from('<IIII', data, off + 8)
    if cmd == 0x19:
        name = data[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<QQQQ', data, off + 24)
        nsects = struct.unpack_from('<I', data, off + 64)[0]
        segments.append((name, vmaddr, vmsize, fileoff, filesize, nsects))
    off += size

symoff, nsyms, stroff, strsize = symtab
for i in range(nsyms):
    strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', data, symoff + i * 16)
    if strx == 0:
        continue
    end = data.index(b'\0', stroff + strx)
    name = data[stroff + strx:end].decode(errors='replace')
    if name == '_bootsessionuuid_string':
        print('symbol %s' % name)
        print('  n_type=%#x n_sect=%d n_desc=%#x n_value=%#x' % (ntype, nsect, ndesc, value))
        for seg in segments:
            sname, vmaddr, vmsize, fileoff, filesize, nsects = seg
            if vmaddr <= value < vmaddr + vmsize:
                print('  segment %s: vmaddr=%#x fileoff=%#x -> file offset %#x'
                      % (sname, vmaddr, fileoff, fileoff + (value - vmaddr)))
        break
else:
    print('symbol not found by that exact name')
