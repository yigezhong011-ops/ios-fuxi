#!/usr/bin/env python3
"""Where key messages sit on disk among blocks new since an older lscan, to tell boots apart. Read-only. Usage: read-auto200p2.py <old lscan> <new lscan>"""
import hashlib
import re
import sys

old, new = sys.argv[1:3]
KEYS = {'HEVC': b'CMPhotoCompressionSessionAddImage', 'store': b'generalErrorDomain', 'ar200': b'sheng-autoreset=200', 'ar150': b'sheng-autoreset=150',
        'focus4': b'boot-ui-focus4=SpringBoard', 'stnn': b'Data store migration not needed'}


def blocks(path):
    b = open(path, 'rb').read()
    marks = list(re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b))
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(b)
        yield int(m.group(1)), b[m.end():end]


seen = {hashlib.sha1(c).digest() for _, c in blocks(old)}
fresh = sorted((o, c) for o, c in blocks(new) if hashlib.sha1(c).digest() not in seen)
print('offset range', fresh[0][0], fresh[-1][0])
GAP = 16 * 1024 * 1024
groups, cur = [], [fresh[0]]
for x in fresh[1:]:
    if x[0] - cur[-1][0] > GAP:
        groups.append(cur); cur = []
    cur.append(x)
groups.append(cur)
print('groups (split on a gap over 16 MiB):', len(groups))
for g in groups:
    t = b''.join(c for _, c in g)
    row = ' '.join(f'{k}={t.count(v)}' for k, v in KEYS.items())
    pids = sorted({int(p) for p in re.findall(rb'\[osservice<com\.apple\.PosterBoard>:(\d+)\]', t)})
    print(f'{g[0][0]:>14} +{(g[-1][0]-g[0][0])//1048576:>5} MiB blocks={len(g):>5} {row} PosterBoard pids={pids[:8]}')
print('--- per block with a key message, in disk order')
for o, c in fresh:
    hits = [f'{k}={c.count(v)}' for k, v in KEYS.items() if c.count(v)]
    if hits:
        print(o, ' '.join(hits))
