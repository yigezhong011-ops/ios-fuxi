#!/usr/bin/env python3
"""Who touches an address in a kernel: adrp + add/ldr/str with the page offset, in the executable segments. Read-only.
Usage: find-coh-readers.py <kernel> <hex addr> [hex addr ...]"""
import re
import struct
import subprocess
import sys

K = sys.argv[1]
targets = [int(a, 16) for a in sys.argv[2:]]
out = subprocess.run(['llvm-objdump', '--macho', '--private-headers', K], capture_output=True, text=True).stdout
segs = [(m[1], int(m[2], 16), int(m[4]), int(m[5])) for m in
        re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)', out)]
d = open(K, 'rb').read()
nm = subprocess.run(['llvm-nm', '-n', K], capture_output=True, text=True).stdout.splitlines()
syms = sorted((int(l.split()[0], 16), l.split()[-1]) for l in nm if len(l.split()) == 3 and l.split()[1] in 'tT' or (len(l.split()) == 3 and l.split()[1] in 'sS'))


def name(a):
    lo, hi = 0, len(syms) - 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if syms[mid][0] <= a:
            lo = mid
        else:
            hi = mid - 1
    return syms[lo][1][:60] + '+' + hex(a - syms[lo][0])


for t in targets:
    print(f'== {t:#x}')
    pg, off = t & ~0xfff, t & 0xfff
    for n, v, fo, fs in segs:
        if 'EXEC' not in n:
            continue
        for o in range(fo, fo + fs - 4, 4):
            w = struct.unpack_from('<I', d, o)[0]
            if w & 0x9f000000 != 0x90000000:
                continue
            pc = v + o - fo
            imm = ((w >> 29) & 3) | (((w >> 5) & 0x7ffff) << 2)
            if imm & (1 << 20):
                imm -= 1 << 21
            if (pc & ~0xfff) + (imm << 12) != pg:
                continue
            reg = w & 31
            for j in range(1, 40):
                x = struct.unpack_from('<I', d, o + 4 * j)[0]
                if x & 0xffc00000 == 0x91000000 and (x >> 5) & 31 == reg and (x >> 10) & 0xfff == off:
                    print(f'  add  {pc + 4 * j:#x} {name(pc)} (x{x & 31})')
                    break
                size = x >> 30
                if x & 0x3fc00000 in (0x39400000, 0x39000000) and (x >> 5) & 31 == reg and ((x >> 10) & 0xfff) << size == off:
                    print(f'  {"ldr" if x & 0x400000 else "str"}  {pc + 4 * j:#x} {name(pc)} (r{x & 31})')
                    break
