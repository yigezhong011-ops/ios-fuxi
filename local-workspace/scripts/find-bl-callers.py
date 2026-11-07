#!/usr/bin/env python3
"""Who calls a kernel symbol: direct bl and b instructions in the executable segments. Read-only.
Usage: find-bl-callers.py <kernel> <symbol> [symbol ...]"""
import bisect
import re
import struct
import subprocess
import sys

K = sys.argv[1]
out = subprocess.run(['llvm-objdump', '--macho', '--private-headers', K], capture_output=True, text=True).stdout
segs = [(m[1], int(m[2], 16), int(m[4]), int(m[5])) for m in
        re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)', out)]
d = open(K, 'rb').read()
nm = [l.split() for l in subprocess.run(['llvm-nm', '-n', K], capture_output=True, text=True).stdout.splitlines()]
syms = {p[2]: int(p[0], 16) for p in nm if len(p) == 3}
code = sorted((int(p[0], 16), p[2]) for p in nm if len(p) == 3 and p[1] in 'tTsS')
addrs = [a for a, _ in code]
targets = {syms[s]: s for s in sys.argv[2:] if s in syms}
for s in sys.argv[2:]:
    if s not in syms:
        print('no symbol', s)
hits = {s: [] for s in targets.values()}
for n, v, fo, fs in segs:
    if 'EXEC' not in n:
        continue
    for o in range(fo, fo + fs - 3, 4):
        w = struct.unpack_from('<I', d, o)[0]
        if w & 0x7c000000 != 0x14000000:
            continue
        imm = w & 0x3ffffff
        if imm & (1 << 25):
            imm -= 1 << 26
        pc = v + o - fo
        t = pc + imm * 4
        if t in targets:
            i = bisect.bisect_right(addrs, pc) - 1
            hits[targets[t]].append('%#x %s %s+%#x' % (pc, 'bl' if w >> 31 else 'b', code[i][1][:50], pc - code[i][0]))
for s, h in hits.items():
    print('%s: %d' % (s, len(h)))
    for x in h[:6]:
        print('   ', x)
