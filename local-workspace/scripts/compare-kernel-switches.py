#!/usr/bin/env python3
"""Which GPU switches does each kernel actually understand? Compare the expert
payload kernel, the GPU16 kernel, and search for the staged bring-up names."""
import re
from pathlib import Path

KERNELS = {
    'expert': Path('/mnt/e/DSH-Fuxi/kernel-gpu16.macho'),          # 用户给的 GPU16 内核
}
# 专家内核在 payload 卷里，先取出来
import subprocess

def extract_expert_kernel() -> Path:
    out = Path('/root/fuxi/expert-kernel.macho')
    if out.exists():
        return out
    import os
    os.system('for m in $(mount | awk \'/vfat|msdos/{print $3}\'); do umount -l "$m" 2>/dev/null; done')
    os.system('mkdir -p /root/fuxi/mnt/expert && mount -t vfat -o loop,ro /mnt/e/DSH-Fuxi/unixnu-expert-boot.img /root/fuxi/mnt/expert 2>/dev/null')
    # 专家镜像是 boot.img，不是 FAT —— 从 gzip 主体里切
    import struct, zlib
    d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
    hsize = struct.unpack_from('<I', d, 20)[0]
    ksize = struct.unpack_from('<I', d, 8)[0]
    start = (hsize + 4095) // 4096 * 4096
    un = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = un.decompress(d[start:start + ksize])
    fat = None
    for m in range(0, 8 << 20, 2):
        bs = body[m:m + 512]
        if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
            fat = m
            break
    total = struct.unpack_from('<I', body, fat + 32)[0]
    open('/root/fuxi/expert-payload-vol.img', 'wb').write(body[fat:fat + total * 512])
    os.system('for m in $(mount | awk \'/vfat|msdos/{print $3}\'); do umount -l "$m" 2>/dev/null; done')
    os.system('mkdir -p /root/fuxi/mnt/ep && mount -t vfat -o loop,ro /root/fuxi/expert-payload-vol.img /root/fuxi/mnt/ep')
    src = Path('/root/fuxi/mnt/ep/EFI/UniXNU/Payloads/kernel.macho')
    out.write_bytes(src.read_bytes())
    os.system('umount /root/fuxi/mnt/ep 2>/dev/null')
    return out


expert = extract_expert_kernel()
KERNELS['expert(用户态那版)'] = expert

SWITCHES = [b'sheng-gpu-start', b'sheng-gpu-match', b'sheng-gpu-run', b'sheng-gpu-addon',
            b'sheng-gpu-metal', b'sheng-fb-gpu', b'fuxi-owner-skip-root-auth',
            b'panic_on_crash_disabled', b'fuxi-enable-ignition']

for label, path in KERNELS.items():
    data = path.read_bytes()
    print('=== %s  %d 字节' % (label, len(data)))
    for s in SWITCHES:
        print('   %-28s %s' % (s.decode(), '有' if s in data else '—'))
    # 是否含 fuxi 的 ZAP（12,088 字节 ELF）特征
    zap = Path('/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn').read_bytes()
    print('   含 ODM ZAP 前 64 字节:', zap[:64] in data)
    print('   含 ODM ZAP 中段 64 字节:', zap[4000:4064] in data)
