#!/usr/bin/env python3
"""Parse the 2 MB boot image and say what it contains."""
import struct

p = '/mnt/c/Users/USER/Downloads/BACKUP-ufs-works.img'
d = open(p, 'rb').read()
print('大小', len(d), '字节')
assert d[:8] == b'ANDROID!'
(kernel_size, kernel_addr, ramdisk_size, ramdisk_addr, second_size, second_addr,
 tags_addr, page_size, header_version, os_version) = struct.unpack('<10I', d[8:48])
print('kernel_size=%d kernel_addr=%#x' % (kernel_size, kernel_addr))
print('ramdisk_size=%d ramdisk_addr=%#x' % (ramdisk_size, ramdisk_addr))
print('second_size=%d tags=%#x page_size=%d header_version=%d os_version=%#x'
      % (second_size, tags_addr, page_size, header_version, os_version))
name = d[48:48+16].split(b'\0')[0]
cmdline = d[64:64+512].split(b'\0')[0]
print('board name:', name)
print('cmdline:', cmdline.decode(errors='replace')[:300])
# 页对齐后找内核
PAGE = page_size or 2048
pad = lambda n: (n + PAGE - 1) // PAGE * PAGE
koff = pad(48 + 512 + 32 + 1024)  # v0 header is 1632 bytes
print('内核起点(估算):', koff)
k = d[koff:koff + min(kernel_size, 64)]
print('内核前 16 字节:', k[:16].hex())
# 找特征串
for marker in (b'BootShim', b'UEFI', b'LinuxLoader', b'Mu-Silicium', b'SILICIUM', b'unixnu'):
    print('  含 %-12s: %d' % (marker.decode(), d.count(marker)))
