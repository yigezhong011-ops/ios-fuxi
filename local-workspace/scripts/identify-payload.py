#!/usr/bin/env python3
"""Say what kind of image the UniXNU payload.img is."""
import pathlib

p = pathlib.Path('/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img')
d = open(p, 'rb').read(4096)
print('文件大小', p.stat().st_size, '=', p.stat().st_size // (1024*1024), 'MiB')
print('前 32 字节:', d[:32].hex())
print('ASCII:', ''.join(chr(b) if 32 <= b < 127 else '.' for b in d[:32]))

sig = {
    b'FAT16': 'FAT16', b'FAT32': 'FAT32', b'EXFAT': 'exFAT',
    b'\x53\xef': 'ext2/3/4', b'NXSB': 'APFS', b'HFSJ': 'HFS+', b'HX': 'HFS+',
    b'\xeb\x3c\x90': 'FAT boot sector', b'\xeb\x76\x90': 'exFAT boot sector',
}
for k, name in sig.items():
    if d[:len(k)] == k or k in d[:512]:
        print('识别为:', name)

# 常见偏移的签名
print('偏移 0x36:', d[0x36:0x3a])
print('偏移 0x52:', d[0x52:0x5a])
print('偏移 1024:', d[1024:1024+8].hex())
