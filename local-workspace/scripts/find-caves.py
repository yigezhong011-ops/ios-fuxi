#!/usr/bin/env python3
"""Executable segments/sections of a kernel and the zero runs at their ends (candidate code caves). Usage: find-caves.py <kernel>"""
import struct
import sys

k = open(sys.argv[1], 'rb').read()
ncmds = struct.unpack_from('<I', k, 16)[0]
off = 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        seg = k[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize, maxprot, initprot, nsects, flags = struct.unpack_from('<4Q4I', k, off + 24)
        if initprot & 4:
            print(f'{seg:16s} va {vmaddr:#x} vmsize {vmsize:#x} filesize {filesize:#x} prot {initprot}')
            so = off + 72
            for _ in range(nsects):
                sect = k[so:so + 16].split(b'\0')[0].decode()
                addr, ssize = struct.unpack_from('<QQ', k, so + 32)
                end = addr + ssize
                # zero run from the section end up to the next 16K boundary (or the segment's file end)
                lim = min((end + 0x3fff) & ~0x3fff, vmaddr + filesize)
                fo = fileoff + end - vmaddr
                run = 0
                while end + run < lim and k[fo + run] == 0:
                    run += 1
                print(f'   {sect:16s} {addr:#x}..{end:#x}  zero tail {run:#x} bytes to {lim:#x}')
                so += 80
    off += size
