#!/usr/bin/env python3
"""Summarise UniXNU boot.img files: header v3 fields, gzip/dtb split, decompressed size,
ARM64 Image header of the decompressed loader, and where the FAT volume starts.
Usage: bootimg-info.py <boot.img>..."""
import struct
import sys
import zlib

for path in sys.argv[1:]:
    data = open(path, 'rb').read()
    ksize, rsize, osv, hsize = struct.unpack_from('<4I', data, 8)
    hver = struct.unpack_from('<I', data, 40)[0]
    kernel = data[4096:4096 + ksize]
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = d.decompress(kernel)
    gz_len = ksize - len(d.unused_data)
    tail = d.unused_data
    text_offset, image_size, flags = struct.unpack_from('<QQQ', body, 8)
    magic = body[56:60]
    fat = next((m for m in range(0, min(len(body), 8 << 20) - 512, 2)
                if body[m + 0x52:m + 0x5a].startswith(b'FAT32') and body[m + 0x1fe:m + 0x200] == b'\x55\xaa'), None)
    print(f'{path}\n  file {len(data)}  hdr v{hver} kernel {ksize} ramdisk {rsize} os_version {osv:#x}\n'
          f'  gzip {gz_len}  appended {len(tail)} (dtb magic {tail[:4].hex()})  decompressed {len(body)}\n'
          f'  Image: magic {magic!r} text_offset {text_offset:#x} image_size {image_size:#x} flags {flags:#x}  FAT at {fat:#x}')
