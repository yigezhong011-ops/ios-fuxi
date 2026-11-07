#!/usr/bin/env python3
"""Read-only: PosterBoard framework strings about the store's database and directories, with the code that uses each. Usage: read-store-strings.py <dsc dir> <regex>"""
import importlib.util
import re
import struct
import sys
args = sys.argv[1:]
sys.argv = ['x', args[0]]
spec = importlib.util.spec_from_file_location('c', '/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
pat = re.compile(args[1].encode(), re.I)
want = {}
for name in ('__cstring', '__oslogstring'):
    a, n = c.sec[name]
    b = c.rd(a, n)
    for m in re.finditer(rb'[^\0]+', b):
        if pat.search(m[0]):
            want[a + m.start()] = m[0].decode('latin1')[:150]
tx, n = c.sec['__text']
t = c.rd(tx, n)
hits = {}
for off in range(0, n - 8, 4):
    i = struct.unpack_from('<I', t, off)[0]
    if i & 0x9f000000 != 0x90000000:
        continue
    imm = ((i >> 29) & 3) | (((i >> 5) & 0x7ffff) << 2)
    if imm & (1 << 20):
        imm -= 1 << 21
    va = tx + off
    page = (va & ~0xfff) + (imm << 12)
    rd_ = i & 31
    for k in (1, 2, 3):
        if off + 4 * k + 4 > n:
            break
        x = struct.unpack_from('<I', t, off + 4 * k)[0]
        if x & 0xffc00000 == 0x91000000 and (x >> 5) & 31 == rd_:
            s = page + ((x >> 10) & 0xfff)
            if s in want:
                hits.setdefault(s, []).append(va)
            break
for s, txt in sorted(want.items()):
    print(hex(s), txt, '<-', ' '.join(hex(v) for v in hits.get(s, [])[:5]))
