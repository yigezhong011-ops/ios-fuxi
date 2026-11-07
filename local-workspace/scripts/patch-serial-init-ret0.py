#!/usr/bin/env python3
"""Make _serial_init return 0 at once in a COPY of the touch kernel.

fuxi has no usable UART, and the bisect (fts6/9b reset, fts8b hangs) puts the hang
inside _serial_init (PI3_UART path of the BCM2837 build). The first two instructions
become `mov w0, #0; ret`.
Usage: patch-serial-init-ret0.py <kernel.macho>   (patched in place)"""
import struct
import subprocess
import sys

MOV_W0_0 = 0x52800000
RET = 0xD65F03C0
EXPECT_FIRST = 0xD10183FF          # sub sp, sp, #0x60


def segments(data):
    magic, _, _, _, ncmds, _, _, _ = struct.unpack_from('<8I', data, 0)
    if magic != 0xFEEDFACF:
        raise SystemExit('not a 64-bit Mach-O')
    off = 32
    for _ in range(ncmds):
        cmd, size = struct.unpack_from('<II', data, off)
        if cmd == 0x19:            # LC_SEGMENT_64
            vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', data, off + 24)
            yield vmaddr, filesize, fileoff
        off += size


def file_offset(data, va):
    for vmaddr, filesize, fileoff in segments(data):
        if vmaddr <= va < vmaddr + filesize:
            return fileoff + va - vmaddr
    raise SystemExit(f'{va:#x} is not in any segment')


path = sys.argv[1]
nm = subprocess.run(['llvm-nm', '--defined-only', path], capture_output=True, text=True, check=True).stdout
va = next(int(l.split()[0], 16) for l in nm.splitlines() if l.split()[-1] == '_serial_init')
data = bytearray(open(path, 'rb').read())
off = file_offset(data, va)
first = struct.unpack_from('<I', data, off)[0]
if first == MOV_W0_0:
    print(f'_serial_init at {va:#x} already patched')
    sys.exit(0)
if first != EXPECT_FIRST:
    raise SystemExit(f'_serial_init at {va:#x} starts with {first:#010x}, expected {EXPECT_FIRST:#010x}')
struct.pack_into('<II', data, off, MOV_W0_0, RET)
open(path, 'wb').write(data)
print(f'_serial_init at {va:#x} (file {off:#x}) -> mov w0,#0; ret')
