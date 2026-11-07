#!/usr/bin/env python3
"""Independent verification of everything this session produced.

Checks, in order:
  1. t32-gpu4.img exists, is structurally like the known-good t32-bl-daily.img, and its
     payload carries the expected kernel, ADT, addon client list and boot arguments.
  2. The Data seed region is untouched (only a handful of small ranges differ from the
     source volume).
  3. The wallpaper overlay files exist and main.caml points at the PNG names.
  4. The request document exists and cites the commits we actually fetched.
"""
import hashlib
import re
import struct
import subprocess
import zlib
from pathlib import Path

E = Path('/mnt/e/DSH-Fuxi')
ok = []
bad = []


def check(name, cond, detail=''):
    (ok if cond else bad).append(name)
    print('%s %-56s %s' % ('PASS' if cond else 'FAIL', name, detail))


def payload_of(image):
    data = Path(image).read_bytes()
    hsize = struct.unpack_from('<I', data, 20)[0]
    ksize = struct.unpack_from('<I', data, 8)[0]
    start = (hsize + 4095) // 4096 * 4096
    un = zlib.decompressobj(16 + zlib.MAX_WBITS)
    body = un.decompress(data[start:start + ksize])
    tree = un.unused_data
    fat = None
    for m in range(0, 8 << 20, 2):
        bs = body[m:m + 512]
        if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
            fat = m
            break
    total = struct.unpack_from('<I', body, fat + 32)[0]
    return data, body, tree, body[fat:fat + total * 512], fat


print('=== 1. 镜像结构 ===')
img = E / 't32-gpu4.img'
check('t32-gpu4.img 存在', img.exists(), '%d B' % img.stat().st_size if img.exists() else '')
good = E / 't32-bl-daily.img'
d1, b1, t1, p1, f1 = payload_of(img)
d2, b2, t2, p2, f2 = payload_of(good)
check('与日常版同一 payload 偏移', f1 == f2, '%d vs %d' % (f1, f2))
check('与日常版同一设备树长度', len(t1) == len(t2), '%d vs %d' % (len(t1), len(t2)))
check('payload 大小一致', len(p1) == len(p2), '%d' % len(p1))

work = Path('/root/verify-final')
work.mkdir(exist_ok=True)
(work / 'p.img').write_bytes(p1)


def mtype(path):
    return subprocess.run(['mtype', '-i', str(work / 'p.img'), path], capture_output=True).stdout


print('\n=== 2. payload 内容 ===')
k = mtype('::/EFI/UniXNU/Payloads/kernel.macho')
src = Path('/root/fuxi/t32/kernel-t32-gpu4.macho').read_bytes()
check('内核与源文件一致', k == src, '%d B' % len(k))
adt = mtype('::/EFI/UniXNU/Payloads/kernel.macho.adt')
check('ADT 13,944 B', len(adt) == 13944, '%d B' % len(adt))

addon = mtype('::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon')
check('附加包 12,172,992 B', len(addon) == 12172992, '%d B' % len(addon))
count, _, tot = struct.unpack_from('<IIQ', addon, 8)
off, entries = 24, {}
for _ in range(count):
    nlen, mode, size, csize = struct.unpack_from('<IIQQ', addon, off)
    off += 24
    name = addon[off:off + nlen - 1].decode()
    off += nlen + (-nlen % 8)
    packed = addon[off:off + csize]
    off += csize + (-csize % 8)
    entries[name] = zlib.decompress(packed)
clients = entries.get('addons/NativeAdrenoMetal.clients', b'').decode().splitlines()
real = [c for c in clients if c and not c.startswith('zz-filler')]
check('clients 名单正确', real == ['SpringBoard', 'WidgetRenderer_Default',
                                   'iconservicesagent', 'Preferences'], ', '.join(real))
check('bluetoothd 已移除', 'daemons/com.apple.bluetoothd.plist' not in entries)
check('libvulkan 仍在（metal2vulkan 需要）', 'addons/NativeAdrenoMetal.bundle/libvulkan_freedreno.dylib' in entries)

toml = mtype('::/EFI/UniXNU/unixnu.toml').decode()
args = re.search(r'args = "([^"]*)"', toml).group(1).split()
for want, present in (('-v', False), ('boot-progress=2', False), ('qcom-usb-debug=1', False),
                      ('sheng-fb-gpu=1', True), ('sheng-gpu-pause-us=100', True),
                      ('sheng-backlight=1', True), ('sheng-data-persist=2', True),
                      ('sheng-dpu=3', True)):
    check('参数 %s %s' % (want, '在' if present else '不在'), (want in args) == present)

print('\n=== 3. Data 种子（卷差异） ===')
r = subprocess.run(['python3', '/mnt/e/DSH-Fuxi/dump/wsl/diff-variant-vol.py',
                    '/root/fuxi/t32/vol.img', '/root/fuxi/variant-t32-gpu4/vol.img'],
                   capture_output=True, text=True)
ranges = [l for l in r.stdout.splitlines() if l.strip().startswith('0x')]
check('只有少量小区间被改写', len(ranges) <= 8, '%d 个区间，每个 64 KiB' % len(ranges))

print('\n=== 4. 壁纸覆盖文件 ===')
wp = E / 'wallpaper-overlay'
for name, lo in (('J120.png', 5_000_000), ('J120-Dark.png', 5_000_000),
                 ('J120-q92.jpg', 300_000), ('J120-Dark-q92.jpg', 300_000),
                 ('main.caml', 100_000), ('index.xml', 1_000), ('assetManifest.caml', 100)):
    p = wp / name
    check('壁纸 %s' % name, p.exists() and p.stat().st_size >= lo,
          '%d B' % p.stat().st_size if p.exists() else '缺失')
caml = (wp / 'main.caml').read_text(errors='replace')
check('main.caml 指向 PNG', '"/J120.png"' in caml or '"J120.png"' in caml)
check('main.caml 不再指向 HEIC', '.HEIC"/>' not in caml)

print('\n=== 5. 给作者的请求 ===')
req = E / 'REQUEST-ljhhkx529-gpu-2026-11-02.md'
text = req.read_text() if req.exists() else ''
check('请求文档存在', req.exists(), '%d 字节' % len(text))
for sha in ('b82fa275', '4db2aa75', '5106df65', '07549e60'):
    check('引用提交 %s' % sha, sha in text)

print('\n=== 汇总 ===')
print('通过 %d 项，失败 %d 项' % (len(ok), len(bad)))
if bad:
    for name in bad:
        print('  失败:', name)
