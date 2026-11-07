#!/usr/bin/env python3
# Adds udid-version=2 to /product of an ADT, as a stock iPhone15,2 has it. Refuses if the property exists or the tree does not parse to the end. Usage: <in> <out>
import struct, sys
d = bytearray(open(sys.argv[1], 'rb').read())
found = []
def node(at, path):
    head = at
    np, nc = struct.unpack_from('<II', d, at); at += 8
    nm = '?'; have = False
    for _ in range(np):
        name = d[at:at + 32].split(b'\0')[0].decode('ascii', 'replace')
        real = struct.unpack_from('<I', d, at + 32)[0] & 0x7fffffff
        if name == 'name':
            nm = bytes(d[at + 36:at + 36 + real]).split(b'\0')[0].decode()
        if name == 'udid-version':
            have = True
        at += 36 + ((real + 3) & ~3)
    full = path + '/' + nm
    if full == '/device-tree/product':
        found.append((head, np, at, have))
    for _ in range(nc):
        at = node(at, full)
    return at
if node(0, '') != len(d):
    raise SystemExit('tree does not parse to the end')
if len(found) != 1:
    raise SystemExit(f'{len(found)} product nodes')
head, np, props_end, have = found[0]
if have:
    raise SystemExit('udid-version is already there')
prop = b'udid-version'.ljust(32, b'\0') + struct.pack('<I', 4) + struct.pack('<I', 2)
struct.pack_into('<I', d, head, np + 1)
d[props_end:props_end] = prop
open(sys.argv[2], 'wb').write(d)
print('added at', hex(props_end), 'size', len(d) - len(prop), '->', len(d))
