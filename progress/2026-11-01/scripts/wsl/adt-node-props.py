#!/usr/bin/env python3
"""Dump every property of one ADT node (by path, e.g. /device-tree/chosen) for several ADT blobs.
Usage: adt-node-props.py /device-tree/chosen a.adt b.adt"""
import struct
import sys


def walk(data, off, path, want, out):
    nprops, nchildren = struct.unpack_from('<II', data, off)
    off += 8
    props = []
    for _ in range(nprops):
        name = data[off:off + 32].split(b'\0')[0].decode(errors='replace')
        size = struct.unpack_from('<I', data, off + 32)[0] & 0x7fffffff
        props.append((name, data[off + 36:off + 36 + size]))
        off += 36 + ((size + 3) & ~3)
    node = dict(props).get('name', b'?').split(b'\0')[0].decode(errors='replace')
    full = path + '/' + node
    if full == want:
        out.extend(props)
    for _ in range(nchildren):
        off = walk(data, off, full, want, out)
    return off


def show(v):
    if v and all(32 <= c < 127 or c == 0 for c in v) and v[0] != 0:
        return repr(v.rstrip(b'\0').decode())
    if len(v) in (4, 8, 16, 24, 32):
        fmt = '<%dQ' % (len(v) // 8) if len(v) % 8 == 0 else '<I'
        return ' '.join(f'{x:#x}' for x in struct.unpack(fmt, v))
    return v[:32].hex() + ('...' if len(v) > 32 else '') + f' ({len(v)} B)'


want = sys.argv[1]
for p in sys.argv[2:]:
    data = open(p, 'rb').read()
    out = []
    walk(data, 0, '', want, out)
    print(f'== {p}: {want}')
    for name, v in out:
        print(f'  {name:32} {show(v)}')
