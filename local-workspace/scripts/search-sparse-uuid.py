#!/usr/bin/env python3
"""Search the sparse userdata image (the one flashed to the phone) for the APFS
root volume UUID the payload asks for, and for APFS container signatures.

Parses the Android sparse format so the 8 GB file is read as its data chunks.
"""
import struct
from pathlib import Path

SPARSE = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/userdata/userdata-sparse.simg')
TARGET_HEX = '04769D262CA04825B443E2E5F88300F2'
target = bytes.fromhex(TARGET_HEX)
NXSB = b'NXSB'
APFS_VOL = bytes.fromhex('41504653000011AAAA1100306543ECAC')

SPARSE_MAGIC = 0xED26FF3A
CHUNK_RAW, CHUNK_FILL, CHUNK_DONT_CARE, CHUNK_CRC32 = 0xCAC1, 0xCAC2, 0xCAC3, 0xCAC4

with SPARSE.open('rb') as f:
    header = f.read(28)
    magic, major, minor, fhs, chs, blk, total_blks, total_chunks, csum = struct.unpack('<IHHHHIIII', header)
    print('magic=%#x chunks=%d blk=%d total_blks=%d' % (magic, total_chunks, blk, total_blks))
    if magic != SPARSE_MAGIC:
        raise SystemExit('不是稀疏镜像')

    out_offset = 0
    hits_uuid, hits_nxsb, hits_vol = [], [], []
    for i in range(total_chunks):
        ch = f.read(12)
        if len(ch) < 12:
            break
        ctype, _, csize, tsize = struct.unpack('<HHII', ch)
        total = csize * blk if ctype != CHUNK_DONT_CARE else 0
        data = f.read(total) if total else b''
        if ctype == CHUNK_RAW and data:
            if target in data:
                hits_uuid.append(out_offset + data.find(target))
            at = data.find(NXSB)
            if at >= 0:
                hits_nxsb.append(out_offset + at)
            at = data.find(APFS_VOL)
            if at >= 0:
                hits_vol.append(out_offset + at)
            out_offset += len(data)
        elif ctype == CHUNK_FILL:
            out_offset += tsize
        else:
            out_offset += tsize

print()
print('目标 UUID %s' % TARGET_HEX)
print('  命中位置:', hits_uuid[:5] or '未找到')
print('APFS 容器 NXSB 位置:', hits_nxsb[:5] or '未找到')
print('APFS 卷签名位置:', hits_vol[:5] or '未找到')
print('镜像解出总长 %d 字节 (%.2f GiB)' % (out_offset, out_offset / 2**30))
