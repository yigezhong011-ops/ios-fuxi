#!/usr/bin/env python3
"""Make NativeLegacyDisplay report an iPhone canvas instead of the panel's 1080x2400 (360x800 pt at 3x, which no iPhone has, so
UIKit shows its fallback "rdar:45025538" status bar). In NativeLegacyDisplay::startHardware the boot mode is stored as
  ldr x9, [sp, #0x20]  /  str w9, [x19, #0x16b0]  /  str w8, [x19, #0x16b4]
The ldr becomes a branch to a stub in the code cave that stores W x H, reloads x9 as before and returns after the stores.
Usage: patch-canvas.py <kernel in> <kernel out> <width> <height> [stub va]   (default stub: cave start + 0x700)"""
import struct
import subprocess
import sys

src, dst, width, height = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
k = bytearray(open(src, 'rb').read())
ncmds = struct.unpack_from('<I', k, 16)[0]
segs, off = [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        segs.append((k[off + 8:off + 24].split(b'\0')[0].decode(), *struct.unpack_from('<4Q', k, off + 24)))
    off += size


def foff(va):
    for name, vmaddr, vmsize, fileoff, filesize in segs:
        if name == '__TEXT_EXEC' and vmaddr <= va < vmaddr + filesize:
            return fileoff + va - vmaddr
    raise SystemExit(f'{va:#x} not in __TEXT_EXEC')


def word(va):
    return struct.unpack_from('<I', k, foff(va))[0]


nm = subprocess.run(['llvm-nm', '--defined-only', src], capture_output=True, text=True, check=True).stdout
fn = next(int(l.split()[0], 16) for l in nm.splitlines() if l.endswith(' __ZN19NativeLegacyDisplay13startHardwareEv'))
# find the exact three-instruction sequence inside the function
site = None
for va in range(fn, fn + 0x400, 4):
    if word(va) == 0xF94013E9 and word(va + 4) == 0xB916B269 and word(va + 8) == 0xB916B668:
        site = va
        break
if site is None:
    raise SystemExit('ldr x9,[sp,#0x20] / str w9,[x19,#0x16b0] / str w8,[x19,#0x16b4] not found in startHardware')
hib_end = None
for name, vmaddr, vmsize, fileoff, filesize in segs:
    if name == '__TEXT_EXEC':
        seg_end = vmaddr + filesize
start = seg_end
while word(start - 4) == 0:
    start -= 4
cave = (start + 0x3f) & ~0x3f
stub = int(sys.argv[5], 0) if len(sys.argv) > 5 else None
# the cave holds the button/brightness blob first; the default stub address is 0x700 after the zero run's start of the
# ORIGINAL kernel, which the caller passes as the patched kernel, so recompute from the first nonzero byte after the blob.
if stub is None:
    stub = cave + 0x700
    if stub + 24 > seg_end:
        raise SystemExit('no room for the stub')
if any(k[foff(stub):foff(stub) + 24]):
    raise SystemExit(f'stub area {stub:#x} not empty')


def movz_w9(v):
    if v >= 1 << 16:
        raise SystemExit('dimension too large')
    return 0x52800009 | (v << 5)


def b(frm, to):
    return 0x14000000 | (((to - frm) // 4) & 0x3ffffff)


code = [movz_w9(width), 0xB916B269,          # str w9, [x19, #0x16b0]
        movz_w9(height), 0xB916B669,         # str w9, [x19, #0x16b4]
        0xF94013E9,                          # ldr x9, [sp, #0x20]  (the original instruction)
        b(stub + 20, site + 12)]             # back after the two stores
for i, w in enumerate(code):
    struct.pack_into('<I', k, foff(stub) + 4 * i, w)
struct.pack_into('<I', k, foff(site), b(site, stub))
open(dst, 'wb').write(k)
print(f'startHardware {fn:#x}: site {site:#x} -> stub {stub:#x}: boot mode {width}x{height}')
