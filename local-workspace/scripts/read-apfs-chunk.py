#!/usr/bin/env python3
"""What APFS objects are in the raw Data sample, and are the file system trees readable as plain bytes? Prints only structure
and directory names from Apple's own paths; no file contents. Read-only."""
import struct
import sys
from collections import Counter
from pathlib import Path

p = Path(sys.argv[1])
BS = 4096
MASK = 0xffffffff


def fletcher(b):
    words = struct.unpack(f'<{len(b) // 4}I', b)
    s1 = s2 = 0
    for w in words:
        s1 = (s1 + w) % MASK
        s2 = (s2 + s1) % MASK
    c1 = MASK - (s1 + s2) % MASK
    c2 = MASK - (s1 + c1) % MASK
    return (c2 << 32) | c1


types = Counter()
fs_nodes = []
sb = []
with p.open('rb') as f:
    i = 0
    while True:
        b = f.read(BS)
        if len(b) < BS:
            break
        if b[:8] != b'\0' * 8 and b != b'\0' * BS:
            ck = struct.unpack_from('<Q', b)[0]
            typ, sub = struct.unpack_from('<II', b, 24)
            if typ & 0xffff in range(1, 0x30) and sub < 0x30:
                if fletcher(b[8:]) == ck:
                    types[(hex(typ), hex(sub))] += 1
                    if b[32:36] == b'NXSB':
                        sb.append((i, 'NXSB', struct.unpack_from('<Q', b, 16)[0]))
                    if b[32:36] == b'APSB':
                        sb.append((i, 'APSB', struct.unpack_from('<Q', b, 16)[0], 'fs_flags', hex(struct.unpack_from('<Q', b, 264)[0]), 'name', b[704:740].split(b'\0')[0]))
                    if sub == 0xe:
                        fs_nodes.append((i, b))
        i += 1
print('blocks', i)
print('valid objects', types.most_common(16))
print(sb[:8])
print('fs tree nodes', len(fs_nodes))
if fs_nodes:
    names = Counter()
    for _, b in fs_nodes[:40]:
        for tok in __import__('re').findall(rb'[A-Za-z0-9_.\- ]{6,}', b[56:]):
            names[tok[:40]] += 1
    print('sample tokens in the first nodes', [k.decode() for k, _ in names.most_common(40)])
    b = fs_nodes[0][1]
    print('first node flags', hex(struct.unpack_from('<H', b, 32)[0]), 'level', struct.unpack_from('<H', b, 34)[0], 'nkeys', struct.unpack_from('<I', b, 36)[0])
