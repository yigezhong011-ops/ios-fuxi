#!/usr/bin/env python3
"""Disassemble whole functions of a Mach-O kernel by symbol name (substring match on the mangled name).
Usage: disasm-sym.py <kernel.macho> <name-substring>... ; each match runs to the next symbol address."""
import bisect
import subprocess
import sys

kernel = sys.argv[1]
nm = subprocess.run(['llvm-nm', '--defined-only', '-n', kernel], capture_output=True, text=True, check=True).stdout
syms = []
for line in nm.splitlines():
    p = line.split()
    if len(p) == 3 and p[1] in 'tTsS':
        syms.append((int(p[0], 16), p[2]))
addrs = sorted({a for a, _ in syms})
for want in sys.argv[2:]:
    for addr, name in syms:
        if want in name:
            i = bisect.bisect_right(addrs, addr)
            end = addrs[i] if i < len(addrs) else addr + 0x400
            end = min(end, addr + 0x1000)
            print(f'===== {name} {addr:#x}..{end:#x}')
            out = subprocess.run(['llvm-objdump', '-d', '--no-show-raw-insn', f'--start-address={addr:#x}',
                                  f'--stop-address={end:#x}', kernel], capture_output=True, text=True).stdout
            print('\n'.join(l for l in out.splitlines() if l.strip() and not l.startswith(kernel)
                            and 'file format' not in l and 'Disassembly of' not in l))
