#!/usr/bin/env python3
"""Pad an ADT to an exact size by appending NULs to one string property (the payload ADT is replaced in place at its old size).
Usage: adt-pad-to.py <adt> <size> /node/path:prop"""
import struct
import sys
import types


def parse(data, off):   # as adt-edit.py, which runs its command line on import
    nprops, nchildren = struct.unpack_from('<II', data, off)
    off += 8
    props = []
    for _ in range(nprops):
        name = data[off:off + 32].split(b'\0')[0].decode()
        raw = struct.unpack_from('<I', data, off + 32)[0]
        size = raw & 0x7fffffff
        props.append([name, data[off + 36:off + 36 + size], raw & 0x80000000])
        off += 36 + ((size + 3) & ~3)
    children = []
    for _ in range(nchildren):
        child, off = parse(data, off)
        children.append(child)
    return {'props': props, 'children': children}, off


def dump(node):
    out = bytearray(struct.pack('<II', len(node['props']), len(node['children'])))
    for name, value, flag in node['props']:
        out += name.encode().ljust(32, b'\0')[:32]
        out += struct.pack('<I', len(value) | flag)
        out += value + b'\0' * (((len(value) + 3) & ~3) - len(value))
    for child in node['children']:
        out += dump(child)
    return bytes(out)


adt = types.SimpleNamespace(parse=parse, dump=dump)
path, size, target = sys.argv[1], int(sys.argv[2]), sys.argv[3]
data = open(path, 'rb').read()
if len(data) > size or (size - len(data)) % 4:
    sys.exit(f'{len(data)} bytes cannot be padded to {size}')
root, _ = adt.parse(data, 0)
node_path, prop = target.split(':')
node = root
for part in [p for p in node_path.split('/') if p][1:]:
    node = next(c for c in node['children'] if any(n == 'name' and v.rstrip(b'\0').decode() == part for n, v, _ in c['props']))
entry = next(p for p in node['props'] if p[0] == prop)
while len(adt.dump(root)) < size:
    entry[1] += b'\0' * 4
out = adt.dump(root)
if len(out) != size:
    sys.exit(f'got {len(out)} bytes, wanted {size}')
open(path, 'wb').write(out)
print(f'{path}: padded to {size} bytes via {target}')
