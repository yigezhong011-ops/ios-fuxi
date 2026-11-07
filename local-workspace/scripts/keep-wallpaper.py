#!/usr/bin/env python3
"""Keep the wallpaper overlay on E: and record the size arithmetic."""
import shutil
from pathlib import Path

src = Path('/root/wallpaper-overlay')
jpg = Path('/root/wallpaper-jpg')
dst = Path('/mnt/e/DSH-Fuxi/wallpaper-overlay')
dst.mkdir(exist_ok=True)

# the PNG originals from the IPSW, converted with sips on the runner
for name in ('J120.png', 'J120-Dark.png', 'index.xml', 'assetManifest.caml', 'main.caml'):
    p = src / name
    if p.exists():
        shutil.copyfile(p, dst / name)
        print('%-22s %10d B' % (name, (dst / name).stat().st_size))

# JPEG versions made here, which are what a rebuild would ship
for name in ('J120-q92.jpg', 'J120-Dark-q92.jpg'):
    p = jpg / name
    if p.exists():
        shutil.copyfile(p, dst / name)
        print('%-22s %10d B' % (name, (dst / name).stat().st_size))

print()
print('addon 可用余量（删掉非必需条目）= 约 27 KB')
print('壁纸最小需求（main.caml 压缩后 ~40 KB + 两张图）= 约 60 KB 起')
print('=> 必须重建载荷，附加包才能变大')
