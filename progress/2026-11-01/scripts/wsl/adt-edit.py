#!/usr/bin/env python3
"""Rewrite properties of an Apple device tree (ADT) blob and write a new blob.

Usage: adt-edit.py IN OUT EDIT...
  EDIT  /node/path:prop=str:TEXT    NUL-terminated string
        /node/path:prop=u32:NUMBER  little-endian 32-bit value
        /node/path:prop=del         remove the property
Paths start at the root node, e.g. /device-tree:model=str:iPhone10,3 or /device-tree/product:artwork-scale-factor=u32:3.
A property that does not exist yet is appended to its node.
"""
import struct
import sys


def parse(data, off):
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


def name_of(node):
    return next(v for n, v, _ in node['props'] if n == 'name').split(b'\0')[0].decode()


def find(root, path):
    parts = [p for p in path.split('/') if p]
    assert parts[0] == name_of(root), path
    node = root
    for part in parts[1:]:
        node = next(c for c in node['children'] if name_of(c) == part)
    return node


src, dst, *edits = sys.argv[1:]
data = open(src, 'rb').read()
root, end = parse(data, 0)
for edit in edits:
    path, rest = edit.split(':', 1)
    prop, spec = rest.split('=', 1)
    node = find(root, path)
    existing = next((p for p in node['props'] if p[0] == prop), None)
    if spec == 'del':
        if existing:
            node['props'].remove(existing)
        print(f'{path}:{prop} removed' if existing else f'{path}:{prop} absent')
        continue
    kind, value = spec.split(':', 1)
    blob = value.encode() + b'\0' if kind == 'str' else struct.pack('<I', int(value, 0))
    if existing:
        existing[1] = blob
    else:
        node['props'].append([prop, blob, 0])
    print(f'{path}:{prop} = {value!r}')
out = dump(root)
assert parse(out, 0)[1] == len(out)
open(dst, 'wb').write(out)
print(f'{src} ({len(data)} B) -> {dst} ({len(out)} B)')
