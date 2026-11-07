#!/usr/bin/env python3
"""Container and sandbox lines around PosterBoard and widgets in the last boot, and repeat-migration evidence. Read-only."""
import re
from collections import Counter
from pathlib import Path

d = next(Path('/root/fuxi/log-oslog1').glob('*/'))
msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
stamps = re.findall(r'\[ *([\d.]+)\]', msg)
print('msgbuf span', stamps[:1], stamps[-1:])
for pat in (r'no system container', r'container path', r'Corpse', r'deny\(1\) [a-z-]+ [^ ]{0,90}'):
    hits = re.findall(r'[ -~]{0,70}%s[ -~]{0,110}' % pat, msg)
    print('==', pat, len(hits))
    c = Counter(re.sub(r'\[ *[\d.]+\]:?|\(\d+\)|\[\d+\]|[0-9A-F]{8}-[0-9A-F-]{27}', '', h)[:170] for h in hits)
    for k, v in c.most_common(25):
        print(f'  {v:4d} {k}')
s = (d / 'slots.txt').read_text(errors='replace')
last = re.split(r'(?m)^(?=#slot )', s)[-1]
print(last[:1500])
