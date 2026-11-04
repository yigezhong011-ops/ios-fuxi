#!/usr/bin/env python3
"""Search the strings lscan pulled out of the raw log chunks. Read-only. Usage: read-lscan.py <lscan.txt>"""
import re
import sys
from collections import Counter

text = open(sys.argv[1], 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
chunks = re.split(r'(?m)^#C ', text)
print('chunks', len(chunks) - 1, 'bytes', len(text))
print(text[-100:].strip().splitlines()[-1])
lines = text.split('\n')
print('distinct lines', len(set(lines)))
kinds = Counter()
for c in chunks[1:]:
    s = c[:6000]
    kinds['tracev3-like' if re.search(r'com\.apple\.[a-zA-Z]+', s) else 'other'] += 1
print(kinds)
PATS = [
    ('poster', r'PosterBoard|PBFPoster|PosterKit|CollectionsPoster|dataStore|data store|Data store'),
    ('container', r'system container|no system container|shared resources directory'),
    ('widget', r'WidgetRenderer|chronod|widget.*(fail|error)'),
    ('wallpaper', r'[Ww]allpaper.*(fail|error|nil|could)|WallpaperKit|\.wallpaper'),
    ('metal', r'native-metal|Metal.*(fail|error)|MTL.*(fail|error)'),
    ('probe', r'adrenoprobed|zz-oslog|sheng'),
]
for name, pat in PATS:
    c = Counter(l[:220] for l in lines if re.search(pat, l))
    print(f'== {name}: {sum(c.values())} lines, {len(c)} distinct')
    for k, v in c.most_common(30):
        print(f'{v:5d} {k}')
