#!/usr/bin/env python3
"""Convert the wallpaper PNGs to JPEG and measure, so they fit the addon."""
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit('没有 Pillow')

src = Path('/root/wallpaper-overlay')
out = Path('/root/wallpaper-jpg')
out.mkdir(exist_ok=True)

for name in ('J120', 'J120-Dark'):
    png = src / (name + '.png')
    img = Image.open(png)
    img = img.convert('RGB')
    for quality in (92, 88, 84, 80):
        target = out / ('%s-q%d.jpg' % (name, quality))
        img.save(target, 'JPEG', quality=quality, optimize=True, progressive=True)
        print('%-12s %-14s %9d B  (%dx%d)' % (name, 'q%d' % quality, target.stat().st_size,
                                              img.size[0], img.size[1]))
    print()
