#!/usr/bin/env python3
"""List ADT properties whose name or value looks like a UUID / platform identity (read-only). Usage: adt-find-uuid.py <adt>"""
import re
import struct
import sys

data = open(sys.argv[1], 'rb').read()
UUID = re.compile(rb'[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}')


def walk(off, path):
    nprops, nchild = struct.unpack_from('<II', data, off)
    off += 8
    props = {}
    for _ in range(nprops):
        name = data[off:off + 32].split(b'\0')[0].decode(errors='replace')
        size = struct.unpack_from('<I', data, off + 32)[0] & 0x7fffffff
        val = data[off + 36:off + 36 + size]
        props[name] = val
        off += 36 + ((size + 3) & ~3)
    node = path + '/' + props.get('name', b'?').split(b'\0')[0].decode(errors='replace')
    for name, val in props.items():
        if re.search(r'uuid|serial|unique|ecid|chip-id|platform|nonce|board-id', name, re.I) or UUID.search(val):
            shown = val.split(b'\0')[0].decode(errors='replace') if val[:1].isalnum() else val[:24].hex()
            print(f'{node}:{name} ({len(val)}) = {shown}')
    for _ in range(nchild):
        off = walk(off, node)
    return off


walk(0, '')
