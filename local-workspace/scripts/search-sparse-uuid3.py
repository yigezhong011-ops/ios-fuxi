#!/usr/bin/env python3
"""Search the flashed sparse userdata for the APFS root volume UUID.

Android sparse chunk layout: after the 12-byte header each chunk carries
total_sz bytes of payload -- csize*blk for RAW, 4 for FILL (the pattern), 0 for
DONT_CARE, 4 for CRC32. Skipping that correctly is what keeps the walk aligned.
"""
import struct
from pathlib import Path

SPARSE = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/userdata/userdata-sparse.simg')
target = bytes.fromhex('04769D262CA04825B443E2E5F88300F2')
NXSB = b'NXSB'
SLICE = 8 << 20

CHUNK_RAW, CHUNK_FILL, CHUNK_DONT_CARE, CHUNK_CRC32 = 0xCAC1, 0xCAC2, 0xCAC3, 0xCAC4

hits_uuid, hits_nxsb = [], []
out_offset = 0
raw_bytes = 0

with SPARSE.open('rb') as f:
    magic, major, minor, fhs, chs, blk, total_blks, total_chunks, csum = struct.unpack('<IHHHHIIII', f.read(28))
    print('chunks=%d blk=%d 逻辑总长 %.2f GiB' % (total_chunks, blk, total_blks * blk / 2**30))
    for i in range(total_chunks):
        ch = f.read(12)
        if len(ch) < 12:
            print('  头部提前结束于第 %d 块' % i)
            break
        ctype, _, csize, tsize = struct.unpack('<HHII', ch)
        if ctype == CHUNK_RAW:
            remaining = csize * blk
            chunk_pos = out_offset
            while remaining > 0:
                data = f.read(min(SLICE, remaining))
                if not data:
                    break
                raw_bytes += len(data)
                if target in data:
                    hits_uuid.append(chunk_pos + data.find(target))
                at = data.find(NXSB)
                if at >= 0:
                    hits_nxsb.append(chunk_pos + at)
                chunk_pos += len(data)
                remaining -= len(data)
            out_offset = chunk_pos
        elif ctype == CHUNK_FILL:
            f.read(4)                 # the fill pattern
            out_offset += tsize
        elif ctype == CHUNK_DONT_CARE:
            out_offset += tsize
        elif ctype == CHUNK_CRC32:
            f.read(4)
        else:
            print('  未知块类型 %#x' % ctype)
            break

print()
print('RAW 数据共 %.2f GiB，解出逻辑长度 %.2f GiB' % (raw_bytes / 2**30, out_offset / 2**30))
print('目标 UUID 命中:', hits_uuid[:5] or '未找到')
print('NXSB 容器 命中:', hits_nxsb[:5] or '未找到')
