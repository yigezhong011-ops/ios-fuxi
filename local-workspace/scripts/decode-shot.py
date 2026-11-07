#!/usr/bin/env python3
"""Turn one screenshot from qud-shot.ps1 into a PNG, checking the frame CRC the kernel sent. Usage: decode-shot.py <base path without extension>"""
import re
import struct
import sys
import zlib

base = sys.argv[1]
meta = dict(re.findall(r'(\w+)=(\S+)', open(base + '.txt').read()))
w, h, raw, crc = int(meta['width']), int(meta['height']), int(meta['bytes']), int(meta['crc32'], 16)
d = open(base + '.bin', 'rb').read()
if len(d) != int(meta['encoded']):
    raise SystemExit(f"have {len(d)} of {meta['encoded']} bytes")
if meta['encoding'] == 'rle':
    rgb = bytearray()
    for at in range(0, len(d), 4):
        rgb.extend(d[at + 1:at + 4] * d[at])
    rgb = bytes(rgb)
else:
    rgb = d
if len(rgb) != raw or zlib.crc32(rgb) != crc:
    raise SystemExit(f'bad frame: {len(rgb)} of {raw} bytes, crc {zlib.crc32(rgb):08x} wanted {crc:08x}')


def chunk(kind, body):
    return struct.pack('>I', len(body)) + kind + body + struct.pack('>I', zlib.crc32(kind + body))


lines = b''.join(b'\0' + rgb[y * w * 3:(y + 1) * w * 3] for y in range(h))
open(base + '.png', 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(lines)) + chunk(b'IEND', b''))
print(f'{base}.png {w}x{h} crc ok, encoded {len(d)} of {raw}')
