#!/usr/bin/env python3
"""Extract the payload volume from each boot image and show its contents and args."""
import struct
from pathlib import Path

for name in ('unixnu-quiet', 'unixnu-touch'):
    img = Path(f'/root/insp-{name}/body.bin')
    if not img.exists():
        print(name, '没有 body.bin')
        continue
    body = img.read_bytes()
    fat = None
    for m in range(0, 8 << 20, 2):
        bs = body[m:m + 512]
        if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
            fat = m
            break
    if fat is None:
        print(name, '找不到 FAT 头')
        continue
    total = struct.unpack_from('<I', body, fat + 32)[0]
    payload = body[fat:fat + total * 512]
    out = Path(f'/root/insp-{name}/payload.img')
    out.write_bytes(payload)
    print('%s: payload %d 字节' % (name, len(payload)))
