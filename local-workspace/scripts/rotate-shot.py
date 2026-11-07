#!/usr/bin/env python3
"""Rotate the phone screenshot and split it into readable halves."""
from pathlib import Path

from PIL import Image

src = Path(r'C:\Users\USER\.dsh\attachments\v1\objects\a8\a8314c80d2bbc0b253d41066614d53dc47ad3b82313c3c5a50b0fdd1526ef11b')
out = Path(r'E:\DSH-Fuxi\read')
out.mkdir(parents=True, exist_ok=True)

im = Image.open(src)
print('原图', im.size)
rot = im.rotate(-90, expand=True)
print('旋转后', rot.size)
rot.save(out / 'rot.png')

w, h = rot.size
# split into two halves and upscale
for name, box in (('left', (0, 0, w // 2, h)), ('right', (w // 2, 0, w, h))):
    part = rot.crop(box)
    scale = 2.0
    part = part.resize((int(part.width * scale), int(part.height * scale)), Image.LANCZOS)
    part.save(out / ('%s.png' % name))
    print(name, part.size)
