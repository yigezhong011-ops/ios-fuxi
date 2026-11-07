#!/usr/bin/env python3
"""Inspect a boot.img before flashing: header version, gzip body, appended device
tree, and whether a UniXNU payload volume rides inside the kernel field."""
import gzip
import struct
import sys
import zlib
from pathlib import Path

p = Path('/mnt/c/Users/USER/Downloads/boot.img')
d = p.read_bytes()
print('文件大小 %d 字节 (%.1f MB)' % (len(d), len(d) / 1e6))
if d[:8] != b'ANDROID!':
    print('不是 Android boot 镜像，前 16 字节:', d[:16].hex())
    raise SystemExit(0)

hver = struct.unpack_from('<I', d, 40)[0]
hsize = struct.unpack_from('<I', d, 20)[0]
ksize, rsize = struct.unpack_from('<II', d, 8)[0], struct.unpack_from('<I', d, 12)[0]
print('header_version=%d  header_size=%d  kernel_size=%d  ramdisk_size=%d'
      % (hver, hsize, ksize, rsize))
cmdline = d[44:44 + 512].split(b'\0')[0].decode(errors='replace') if hver >= 3 else d[64:64+512].split(b'\0')[0].decode(errors='replace')
print('cmdline:', cmdline[:120] or '(空)')

page = 4096 if hver >= 3 else struct.unpack_from('<I', d, 36)[0]
start = (hsize + page - 1) // page * page
kernel = d[start:start + ksize]
print('kernel 前 8 字节:', kernel[:8].hex())

if kernel[:2] == b'\x1f\x8b':
    un = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = un.decompress(kernel)
    tail = un.unused_data
    print('gzip 主体 %d 字节，尾部 %d 字节（设备树: %s）'
          % (len(body), len(tail), tail[:4] == b'\xd0\x0d\xfe\xed'))
    for marker in (b'FUXIESP', b'unixnu.toml', b'kernel.macho', b'FAT32', b'SILICIUM'):
        print('  主体含 %-12s: %s' % (marker.decode(), marker in body))
    # 载荷卷若已拼入，偏移应在固件卷之后
    at = body.find(b'FUXIESP')
    print('  FUXIESP 位置:', at if at >= 0 else '未找到')
else:
    print('kernel 不是 gzip，前 32 字节:', kernel[:32].hex())

for s in (b'UniXNU', b'DARWINBOOT', b'FUXI FIX'):
    print('  全文件含 %-12s: %s' % (s.decode(), s in d))
