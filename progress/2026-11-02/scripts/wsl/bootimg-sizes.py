#!/usr/bin/env python3
"""Header v3 sizes of boot images (kernel section = gzip(loader + payload), ramdisk), to compare images that booted
with images that stopped at the Mi logo. Usage: bootimg-sizes.py <img>..."""
import os
import struct
import sys

for path in sys.argv[1:]:
    with open(path, 'rb') as f:
        h = f.read(4096)
    if h[:8] != b'ANDROID!':
        print(f'{path}: not a boot image')
        continue
    kernel_size, ramdisk_size, os_version, header_size = struct.unpack_from('<4I', h, 8)
    version = struct.unpack_from('<I', h, 40)[0]
    print(f'{os.path.basename(path):24} file={os.path.getsize(path):#010x} kernel={kernel_size:#010x} ({kernel_size / 1048576:.3f} MiB) '
          f'ramdisk={ramdisk_size:#x} header_v={version}')
