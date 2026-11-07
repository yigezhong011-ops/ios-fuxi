#!/usr/bin/env python3
"""Find the source FAT volume inside a header-v3 boot image's decompressed kernel section and list the changed 64 KiB
ranges against it. Usage: diff-bootimg-vs-vol.py <vol.img> <boot.img> [...]"""
import struct
import sys
import zlib

vol = open(sys.argv[1], 'rb').read()
for path in sys.argv[2:]:
    data = open(path, 'rb').read()
    ksize = struct.unpack_from('<I', data, 8)[0]
    body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(data[4096:4096 + ksize])
    base = body.find(vol[:512])
    if base < 0:
        print(path, ': boot sector of the source volume not found')
        continue
    img = body[base:base + len(vol)]
    step = 1 << 16
    runs = []
    for off in range(0, min(len(vol), len(img)), step):
        if vol[off:off + step] != img[off:off + step]:
            if runs and runs[-1][1] == off:
                runs[-1][1] = off + step
            else:
                runs.append([off, off + step])
    print(f'{path}: volume at {base:#x}, {len(runs)} changed ranges, {sum(e - s for s, e in runs) >> 10} KiB')
    for s, e in runs[:12]:
        print(f'  {s:#010x}..{e:#010x} ({(e - s) >> 10} KiB)')
