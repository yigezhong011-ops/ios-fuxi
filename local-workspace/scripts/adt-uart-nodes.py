#!/usr/bin/env python3
"""Print the ADT nodes serial_init() looks at (gpio, aux, uart0/1, boot-console, dockchannel-uart)
plus the arm-io base, for one or more Apple device tree blobs."""
import struct
import sys

WANTED = {b'gpio', b'aux', b'uart0', b'uart1', b'dockchannel-uart', b'arm-io'}


def walk(data, off, path, out):
    nprops, nchildren = struct.unpack_from('<II', data, off)
    off += 8
    props = {}
    for _ in range(nprops):
        name = data[off:off + 32].split(b'\0')[0]
        size = struct.unpack_from('<I', data, off + 32)[0] & 0x7fffffff
        props[name] = data[off + 36:off + 36 + size]
        off += 36 + ((size + 3) & ~3)
    node = props.get(b'name', b'?').split(b'\0')[0]
    full = path + '/' + node.decode(errors='replace')
    if node in WANTED or b'boot-console' in props:
        info = {k.decode(): v for k, v in props.items()
                if k in (b'reg', b'compatible', b'boot-console', b'ranges', b'device_type')}
        out.append((full, info))
    for _ in range(nchildren):
        off = walk(data, off, full, out)
    return off


for p in sys.argv[1:]:
    data = open(p, 'rb').read()
    out = []
    walk(data, 0, '', out)
    print(f'== {p} ({len(data)} bytes)')
    for full, info in out:
        shown = []
        for k, v in info.items():
            if k in ('reg', 'ranges'):
                shown.append(f'{k}=' + ' '.join(f'{x:#x}' for x in struct.unpack_from('<%dQ' % (len(v) // 8), v)))
            else:
                shown.append(f'{k}={v.rstrip(bytes(1))!r}')
        print(f'  {full}: ' + '  '.join(shown))
