#!/usr/bin/env python3
# Read only: the property names of /product and /chosen in an ADT, with lengths; values only for a short allow list, never identifiers. Usage: <adt>
import struct, sys
d = open(sys.argv[1], 'rb').read()
SHOW = {'product-name', 'product-description', 'udid-version', 'device-color', 'compatible', 'model', 'target-type', 'target-sub-type', 'mlb-serial-number-size'}
def node(at, path):
    np, nc = struct.unpack_from('<II', d, at); at += 8
    props = []
    for _ in range(np):
        name = d[at:at + 32].split(b'\0')[0].decode('ascii', 'replace')
        ln = struct.unpack_from('<I', d, at + 32)[0]
        real = ln & 0x7fffffff
        props.append((name, real, ln >> 31, d[at + 36:at + 36 + real], at))
        at += 36 + ((real + 3) & ~3)
    nm = next((p[3].split(b'\0')[0].decode() for p in props if p[0] == 'name'), '?')
    full = path + '/' + nm
    if full in ('/device-tree/product', '/device-tree/chosen', '/device-tree') or nm in ('product', 'chosen'):
        print(full, 'props', np, 'children', nc)
        for n, r, fl, v, a in props:
            s = ''
            if n in SHOW:
                s = repr(v[:40])
            print('   %-32s len %4d %s' % (n, r, s))
    for _ in range(nc):
        at = node(at, full)
    return at
end = node(0, '')
print('parsed', end, 'of', len(d))
