#!/usr/bin/env python3
"""One line per ADT node: path, compatible and reg (first pairs). Diff two of these to compare ADTs.
Usage: adt-tree.py <adt>"""
import struct
import sys


def walk(data, off, path):
    nprops, nchildren = struct.unpack_from('<II', data, off)
    off += 8
    props = {}
    for _ in range(nprops):
        name = data[off:off + 32].split(b'\0')[0].decode(errors='replace')
        size = struct.unpack_from('<I', data, off + 32)[0] & 0x7fffffff
        props[name] = data[off + 36:off + 36 + size]
        off += 36 + ((size + 3) & ~3)
    node = props.get('name', b'?').split(b'\0')[0].decode(errors='replace')
    full = path + '/' + node
    line = full
    if 'compatible' in props:
        line += '  compat=' + props['compatible'].split(b'\0')[0].decode(errors='replace')
    for key in ('reg', 'ranges'):
        v = props.get(key)
        if v and len(v) % 8 == 0:
            line += f'  {key}=' + ' '.join(f'{x:#x}' for x in struct.unpack_from('<%dQ' % min(len(v) // 8, 4), v))
    print(line)
    for _ in range(nchildren):
        off = walk(data, off, full)
    return off


walk(open(sys.argv[1], 'rb').read(), 0, '')
