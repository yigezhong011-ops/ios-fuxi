#!/usr/bin/env python3
"""Verify t32-gpu4.img end to end: the payload inside the image, the addon's client
list, the kernel size, the boot arguments and that the Data seed region is untouched."""
import struct
import subprocess
import zlib
from pathlib import Path

IMG = Path('/mnt/e/DSH-Fuxi/t32-gpu4.img')
BASE = Path('/root/fuxi/t32/vol.img')
VARIANT = Path('/root/fuxi/variant-t32-gpu4/vol.img')

print('=== 1. 镜像 ===')
data = IMG.read_bytes()
print('  大小 %d 字节 (%.1f MB)' % (len(data), len(data) / 1e6))

# Android boot image v3/v4: header 1580 bytes, kernel = gzip(BootShim + FD + FAT)
hsize = struct.unpack_from('<I', data, 20)[0]
ksize = struct.unpack_from('<I', data, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(data[start:start + ksize])
tree = un.unused_data
print('  头 %d, 内核区 %d, 解压后主体 %d, 设备树 %d' % (hsize, ksize, len(body), len(tree)))
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
payload = body[fat:fat + total * 512]
out = Path('/root/verify-gpu4/payload.img')
out.parent.mkdir(exist_ok=True)
out.write_bytes(payload)
print('  payload 起点 %d, 大小 %d' % (fat, len(payload)))

print('\n=== 2. payload 里的文件 ===')
r = subprocess.run(['mdir', '-i', str(out), '-/ ::/EFI/UniXNU/Payloads'],
                   capture_output=True, text=True)
for line in r.stdout.splitlines():
    if 'kernel' in line or 'scratch' in line:
        print('  ', line.strip()[:80])

print('\n=== 3. 取出 addon 并解析名单 ===')
addon = Path('/root/verify-gpu4/addon.bin')
r = subprocess.run(['mtype', '-i', str(out), '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'],
                   capture_output=True)
addon.write_bytes(r.stdout)
print('  addon %d 字节' % len(r.stdout))
d = r.stdout
count, _, tot = struct.unpack_from('<IIQ', d, 8)
print('  NGPUADD2, %d 个条目, header total %d' % (count, tot))
off = 24
for _ in range(count):
    name_len, mode, size, csize = struct.unpack_from('<IIQQ', d, off)
    off += 24
    name = d[off:off + name_len - 1].decode()
    off += name_len + (-name_len % 8)
    packed = d[off:off + csize]
    off += csize + (-csize % 8)
    if name.endswith('.clients'):
        text = zlib.decompress(packed).decode()
        names = [l for l in text.splitlines() if l and not l.startswith('zz-filler')]
        fillers = [l for l in text.splitlines() if l.startswith('zz-filler')]
        print('  clients 名单: %s' % ', '.join(names))
        print('  填充行 %d 个（仅用于等长，不匹配任何进程）' % len(fillers))
    else:
        print('  %-52s %9d → %9d' % (name[:52], size, csize))

print('\n=== 4. 启动参数 ===')
r = subprocess.run(['mtype', '-i', str(out), '::/EFI/UniXNU/unixnu.toml'],
                   capture_output=True, text=True)
import re
m = re.search(r'args = "([^"]*)"', r.stdout)
args = m.group(1).split()
for key in ('-v', 'boot-progress=2', 'qcom-usb-debug=1', 'sheng-fb-gpu=1',
            'sheng-gpu-pause-us=100', 'sheng-backlight=1', 'sheng-data-persist=2'):
    print('  %-24s %s' % (key, '在' if key in args else '不在'))
print('  参数总数', len(args))

print('\n=== 5. 与原卷的差异（Data 种子必须保持完整） ===')
if VARIANT.exists():
    r = subprocess.run(['python3', '/mnt/e/DSH-Fuxi/dump/wsl/diff-variant-vol.py',
                        str(BASE), str(VARIANT)], capture_output=True, text=True)
    for line in r.stdout.splitlines()[:8]:
        print('  ', line[:120])
    for line in r.stderr.splitlines()[:3]:
        print('  !', line[:120])
else:
    print('  变体卷不在')
