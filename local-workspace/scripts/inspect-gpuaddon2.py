#!/usr/bin/env python3
"""Extract the addon from the expert payload and inspect what it carries."""
import shutil
import subprocess
from pathlib import Path

mnt = Path('/root/fuxi/addonmnt')
mnt.mkdir(parents=True, exist_ok=True)
subprocess.run('for m in $(mount | awk \'/vfat|msdos/{print $3}\'); do umount -l "$m" 2>/dev/null; done',
               shell=True, check=False)
subprocess.run(['mount', '-t', 'vfat', '-o', 'loop,ro',
                '/root/fuxi/expert-payload-vol.img', str(mnt)], check=True)
src = mnt / 'EFI/UniXNU/Payloads/kernel.macho.gpuaddon'
out = Path('/root/fuxi/expert-gpuaddon.bin')
shutil.copy(src, out)
subprocess.run(['umount', str(mnt)], check=False)

data = out.read_bytes()
print('addon %d 字节' % len(data))
print('前 32 字节:', data[:32].hex())
print('前 8 字符:', repr(data[:8]))
print()
for name in (b'NativeAdrenoMetal.bundle', b'NativeAdrenoMetal.publish', b'NativeAdrenoMetal.clients',
             b'adrenoprobed', b'MetalPluginName', b'DBRDISK', b'NGPUADD', b'APFS', b'HFS', b'IOKit'):
    print('  %-28s %s' % (name.decode(errors='replace'), '有' if name in data else '没有'))
