#!/usr/bin/env python3
"""Compare the decompressed kernel sections (loader + FAT payload) of two header-v3 boot images, per 64 KiB.
Usage: diff-bootimg-payload.py <a.img> <b.img>"""
import struct
import sys
import zlib


def body(path):
    data = open(path, 'rb').read()
    ksize = struct.unpack_from('<I', data, 8)[0]
    raw = data[4096:4096 + ksize]
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    out = d.decompress(raw)
    return out, len(d.unused_data), d.eof


a, ua, ea = body(sys.argv[1])
b, ub, eb = body(sys.argv[2])
print(f'a: {len(a)} bytes, gzip end {ea}, trailing {ua}')
print(f'b: {len(b)} bytes, gzip end {eb}, trailing {ub}')
for name, x in (('a', a), ('b', b)):
    zero = sum(1 for off in range(0, len(x), 1 << 16) if not x[off:off + (1 << 16)].strip(b'\0'))
    print(f'{name}: {zero} all-zero 64 KiB blocks')
step = 1 << 16
runs = []
for off in range(0, min(len(a), len(b)), step):
    if a[off:off + step] != b[off:off + step]:
        if runs and runs[-1][1] == off:
            runs[-1][1] = off + step
        else:
            runs.append([off, off + step])
print(f'{len(runs)} changed ranges, {sum(e - s for s, e in runs) >> 10} KiB')
for s, e in runs[:40]:
    print(f'  {s:#010x}..{e:#010x} ({(e - s) >> 10} KiB)')
