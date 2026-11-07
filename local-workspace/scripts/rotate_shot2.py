"""Rotate the phone screenshot the right way up and enlarge the text area."""
from pathlib import Path

from PIL import Image

src = Path(r'C:\Users\USER\.dsh\attachments\v1\objects\a8\a8314c80d2bbc0b253d41066614d53dc47ad3b82313c3c5a50b0fdd1526ef11b')
out = Path(r'E:\DSH-Fuxi\read')
out.mkdir(parents=True, exist_ok=True)

im = Image.open(src)
rot = im.rotate(90, expand=True)   # 翻正
rot.save(out / 'upright.png')
w, h = rot.size
print('翻正后', rot.size)

# 文字区域在中间偏上，切成三段放大
bands = [('top', 0.05, 0.40), ('mid', 0.35, 0.70), ('bottom', 0.65, 1.00)]
for name, a, b in bands:
    part = rot.crop((0, int(h * a), w, int(h * b)))
    part = part.resize((part.width * 2, part.height * 2), Image.LANCZOS)
    part.save(out / ('%s.png' % name))
    print(name, part.size)
