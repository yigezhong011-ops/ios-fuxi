#!/usr/bin/env python3
"""Find the code in the PosterBoard framework that references given strings, and disassemble named spots. Read-only.
Usage: read-dsc-xref.py <dsc dir> <mode> ...   mode: x <string>...  |  d <hex addr or +hexoffset> <before> <after> ..."""
import importlib.util
import struct
import sys
sys.argv, args = [sys.argv[0], sys.argv[1]], sys.argv[2:]
spec = importlib.util.spec_from_file_location('c', '/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
base, sec, rd, dump = c.base, c.sec, c.rd, c.dump
tx, txs = sec['__text']
text = rd(tx, txs)


def str_vas(s):
    out = []
    needle = s.encode()
    for name in ('__cstring', '__oslogstring'):
        if name in sec:
            a, n = sec[name]
            d = rd(a, n)
            i = d.find(needle)
            while i >= 0:
                st = d.rfind(b'\0', 0, i) + 1
                out.append(a + st)
                i = d.find(needle, i + 1)
    return sorted(set(out))


def cfstrs(va):
    """__cfstring entries whose data pointer has this low address."""
    if '__cfstring' not in sec:
        return []
    a, n = sec['__cfstring']
    d = rd(a, n)
    hits = []
    for i in range(0, n, 32):
        q = struct.unpack_from('<Q', d, i + 16)[0]
        if (q & 0xfffffffff) + 0x180000000 == va or (q & 0xffffffffff) == va:
            hits.append(a + i)
    return hits


def xrefs(targets):
    res = []
    t = set(targets)
    for off in range(0, txs - 4, 4):
        a = struct.unpack_from('<I', text, off)[0]
        if a & 0x9f000000 != 0x90000000:
            continue
        va = tx + off
        imm = ((a >> 29) & 3) | (((a >> 5) & 0x7ffff) << 2)
        if imm & (1 << 20):
            imm -= 1 << 21
        page = (va & ~0xfff) + (imm << 12)
        rdn = a & 31
        for k in range(1, 6):
            if off + 4 * k + 4 > txs:
                break
            b = struct.unpack_from('<I', text, off + 4 * k)[0]
            if b & 0xff800000 == 0x91000000 and (b >> 5) & 31 == rdn:
                if page + ((b >> 10) & 0xfff) in t:
                    res.append(va)
                break
    return res


if args[0] == 'x':
    for s in args[1:]:
        for v in str_vas(s):
            tg = [v] + cfstrs(v)
            print(f'{s[:60]!r} str {v:#x} cf {[hex(x) for x in tg[1:]]} xrefs', [hex(x) for x in xrefs(tg)])
else:
    r = args[1:]
    for i in range(0, len(r), 3):
        a = base + int(r[i][1:], 16) if r[i][0] == '+' else int(r[i], 16)
        print('== at', hex(a))
        dump(a - int(r[i + 1], 16), int(r[i + 1], 16) + int(r[i + 2], 16), a)
