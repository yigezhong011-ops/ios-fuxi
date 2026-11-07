#!/usr/bin/env python3
"""Inspect the boot image and kernel/payload the user provided."""
import hashlib
import struct
import zlib
from pathlib import Path

for name in ('boot-fuxi-GPU16.img', 'kernel.macho', 'payload.img'):
    p = Path('/mnt/c/Users/USER/Downloads') / name
    if not p.is_file():
        print('%s 不存在' % name)
        continue
    d = p.read_bytes()
    print('=== %s  %d 字节 (%.1f MB)' % (name, len(d), len(d) / 1e6))
    print('    sha256 %s' % hashlib.sha256(d).hexdigest())
    print('    前 16 字节 %s  %r' % (d[:16].hex(), d[:8]))
    if name.endswith('.img') and d[:8] == b'ANDROID!':
        hver = struct.unpack_from('<I', d, 40)[0]
        hsize = struct.unpack_from('<I', d, 20)[0]
        ksize = struct.unpack_from('<I', d, 8)[0]
        rsize = struct.unpack_from('<I', d, 12)[0]
        print('    header_version=%d header_size=%d kernel=%d ramdisk=%d' % (hver, hsize, ksize, rsize))
        page = 4096
        start = (hsize + page - 1) // page * page
        kernel = d[start:start + ksize]
        print('    kernel 前 8: %s' % kernel[:8].hex())
        if kernel[:2] == b'\x1f\x8b':
            un = zlib.decompressobj(16 + zlib.MAX_WBITS)
            body = un.decompress(kernel)
            print('    gzip 主体 %d 字节，尾部 %d 字节（FDT: %s）'
                  % (len(body), len(un.unused_data), un.unused_data[:4] == b'\xd0\x0d\xfe\xed'))
            for marker in (b'FUXIESP', b'FUXIPAYL', b'FAT32', b'kernel.macho', b'kernel.macho.gpuaddon',
                           b'unixnu.toml', b'GPU16', b'gpu16'):
                print('      含 %-22s %s' % (marker.decode(), marker in body))
            at = body.find(b'FUXIPAYL')
            if at < 0:
                at = body.find(b'FUXIESP')
            print('      卷标签偏移:', at)
    elif name == 'payload.img':
        print('    前 512 处标签:', d[0x47:0x52])
    elif name == 'kernel.macho':
        # Mach-O 魔数
        magic = d[:4]
        print('    Mach-O 魔数:', magic.hex(), '(cffaedfe = arm64 LE)')
        ver = [s for s in d[:200000].split(b'\x00') if b'Darwin Kernel Version' in s]
        if ver:
            print('    版本串:', ver[0][:120])
