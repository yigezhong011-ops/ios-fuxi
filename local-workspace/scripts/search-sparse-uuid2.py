#!/usr/bin/env python3
"""Search the flashed sparse userdata for the APFS root volume UUID, streaming
each raw chunk in slices so the 8 GB image never has to fit in memory."""
import struct
from pathlib import Path

SPARSE = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/userdata/userdata-sparse.simg')
target = bytes.fromhex('04769D262CA04825B443E2E5F88300F2')
NXSB = b'NXSB'
APFS_VOL = bytes.fromhex('41504653000011AAAA1100306543ECAC')

CHUNK_RAW, CHUNK_FILL, CHUNK_DONT_CARE, CHUNK_CRC32 = 0xCAC1, 0xCAC2, 0xCAC3, 0xCAC4
SLICE = 8 << 20

hits_uuid, hits_nxsb, hits_vol = [], [], []
out_offset = 0

with SPARSE.open('rb') as f:
    head = f.read(28)
    magic, major, minor, fhs, chs, blk, total_blks, total_chunks, csum = struct.unpack('<IHHHHIIII', head)
    print('chunks=%d blk=%d total=%.2f GiB'
          % (total_chunks, blk, total_blks * blk / 2**30))
    for i in range(total_chunks):
        ch = f.read(12)
        if len(ch) < 12:
            break
        ctype, _, csize, tsize = struct.unpack('<HHII', ch)
        if ctype == CHUNK_RAW:
            remaining = csize * blk
            chunk_pos = out_offset
            while remaining > 0:
                take = min(SLICE, remaining)
                data = f.read(take)
                if not data:
                    break
                if target in data:
                    hits_uuid.append(chunk_pos + data.find(target))
                at = data.find(NXSB)
                if at >= 0:
                    hits_nxsb.append(chunk_pos + at)
                at = data.find(APFS_VOL)
                if at >= 0:
                    hits_vol.append(chunk_pos + at)
                chunk_pos += len(data)
                remaining -= len(data)
            out_offset = chunk_pos
        elif ctype in (CHUNK_FILL, CHUNK_DONT_CARE):
            out_offset += tsize
            if ctype == CHUNK_FILL:
                f.read(4) if csize == 4 else None
        elif ctype == CHUNK_CRC32:
            f.read(4)

print()
print('目标 UUID 命中:', hits_uuid[:5] or '未找到')
print('NXSB 容器 命中:', hits_nxsb[:5] or '未找到')
print('APFS 卷签名 命中:', hits_vol[:5] or '未找到')
print('解出总长 %.2f GiB' % (out_offset / 2**30))
