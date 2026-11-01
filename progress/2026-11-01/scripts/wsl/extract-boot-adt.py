#!/usr/bin/env python3
"""Pull EFI/UniXNU/{unixnu.toml,Payloads/kernel.macho.adt} out of a UniXNU boot.img (header v3,
gzip(loader + FAT32 payload) + dtb as the kernel). Writes <out-prefix>.adt and <out-prefix>.toml.
Usage: extract-boot-adt.py <boot.img> <out-prefix>"""
import os
import struct
import subprocess
import sys
import zlib

img, prefix = sys.argv[1], sys.argv[2]
data = open(img, 'rb').read()
if data[:8] != b'ANDROID!':
    raise SystemExit('not an Android boot image')
kernel_size = struct.unpack_from('<I', data, 8)[0]
kernel = data[4096:4096 + kernel_size]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(kernel)
fat = next(m for m in range(0, len(body) - 512, 2)
           if body[m + 0x52:m + 0x5a].startswith(b'FAT32') and body[m + 0x1fe:m + 0x200] == b'\x55\xaa')
vol = prefix + '.vol'
open(vol, 'wb').write(body[fat:])
env = dict(os.environ, MTOOLS_SKIP_CHECK='1')
for src, dst in (('::/EFI/UniXNU/Payloads/kernel.macho.adt', prefix + '.adt'),
                 ('::/EFI/UniXNU/unixnu.toml', prefix + '.toml')):
    subprocess.run(['mcopy', '-o', '-i', vol, src, dst], check=True, env=env)
os.remove(vol)
print(f'{img}: FAT at {fat:#x}, wrote {prefix}.adt ({os.path.getsize(prefix + ".adt")} B) and {prefix}.toml')
