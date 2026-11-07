#!/usr/bin/env python3
"""PosterBoard and the wallpaper picker in the pulled logs: crashes, launches, GPU refusals. Read-only."""
import re
from collections import Counter
from pathlib import Path

for name in ('log-gpu2', 'log-gpu3', 'log-gpufix'):
    d = next(Path('/root/fuxi', name).glob('*/'))
    msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
    print('=====', name, 'msgbuf chars', len(msg))
    for pat in (r'Corpse', r'/Applications/PosterBoard', r'Poster', r'Wallpaper', r'Preferences\(', r'EXC_|exception|SIGABRT|abort|Fatal|fatal', r'dyld|Library not loaded', r'Sandbox: (PosterBoard|CollectionsPoster|Preferences|WallpaperKit|SpringBoard)[^\n]{0,20}'):
        hits = re.findall(r'.{0,90}(?:%s).{0,130}' % pat, msg)
        print('--', pat, len(hits))
        c = Counter(re.sub(r'[0-9A-F]{8}-[0-9A-F-]{27}', 'UUID', x)[:220] for x in hits)
        for k, v in c.most_common(8):
            print('  ', v, k)
    text = (d / 'slots.txt').read_text(errors='replace')
    rows = Counter()
    for pat in (r'^\[metal askers\] (.*)$', r'^\[gpu clients\] (.*)$'):
        for m in re.finditer(pat, text, re.M):
            for w in re.findall(r'([A-Za-z_][\w.-]+)(?::\d+| \d+/\d+/\d+ (?:s[-\d]) \d+M r\w+)', m[1]):
                rows[w] += 1
    print('-- every process ever seen asking:', sorted(rows))
    refused = set(re.findall(r'([A-Za-z_][\w.-]+) \d+/\d+/\d+ s- \d+M (r[0-9a-f]{2,})', text))
    print('-- refused:', sorted(refused))
    late = [line[:240] for line in text.splitlines() if line.startswith('[gpu clients]')]
    print('-- final clients:', late[-1] if late else '-')
