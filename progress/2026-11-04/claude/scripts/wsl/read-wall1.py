#!/usr/bin/env python3
"""What did the wallpaper test boot do? Compares the two lscan captures block by block and reads the boot log. Read-only on inputs.
Usage: read-wall1.py <before lscan> <after lscan> <log.bin> <out dir>"""
import hashlib
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

before, after, logbin, out = sys.argv[1:5]
out = Path(out)
DEC = '/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py'


def chunks(path):
    t = open(path, 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
    r = {}
    for c in re.split(r'(?m)^#C ', t)[1:]:
        head, _, body = c.partition('\n')
        r[head.split()[0]] = body
    return r


a, b = chunks(before), chunks(after)
old = {hashlib.sha1(x.encode('latin1')).digest() for x in a.values()}
new = {k: v for k, v in b.items() if hashlib.sha1(v.encode('latin1')).digest() not in old}
print('blocks before', len(a), 'after', len(b), 'new', len(new))
text = '\n'.join(new[k] for k in sorted(new, key=int))
out.mkdir(parents=True, exist_ok=True)
(out / 'new.txt').write_text(text, encoding='latin1')
lines = text.split('\n')


def show(title, pat, limit=30, width=300):
    rx = re.compile(pat)
    c = Counter(re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}', '#', l)[:width] for l in lines if rx.search(l))
    print(f'== {title}: {sum(c.values())} lines, {len(c)} distinct')
    for k, v in c.most_common(limit):
        print(f'{v:5d} {k}')


show('wallpaper catalog', r'(?i)Bokeh|DefaultWallpaper|WKWallpaper|wallpaperCollection|D4894D14|Library/Wallpaper|5010')
show('poster process', r'(?i)CollectionsPoster|PBFPoster|PRSWallpaper|PBUIPoster|poster.*(fail|error|nil|unable|invalid|could)|Data store')
show('asserts and metal', r'_bs_assert|failed assertion|native-metal: .*refused|Metal failed')
show('crash reports', r'Logs/CrashReporter/\w+', 20, 120)
show('widget', r'CMPhotoCompression|unableToFinalize|Reload failed|extensionNotFound\(com\.apple\.weather::')

print('== boot log')
o = out / 'log'
subprocess.run(['rm', '-rf', str(o)])
subprocess.run(['python3', '-I', DEC, '--decode', logbin, '--out', str(o)], capture_output=True)
d = next(o.glob('*/'))
print((d / 'header.txt').read_text()[:400])
s = (d / 'slots.txt').read_text(errors='replace')
slots = [x for x in re.split(r'(?m)^(?=#slot )', s) if x.startswith('#slot')]
print('slots', len(slots))
for line in slots[-1].splitlines():
    if re.match(r'(A |\[coherence|\[gpu clients|\[metal askers|\[reset|G |W1 )', line):
        print(' ', line[:260])
print('-- A rows', Counter(re.findall(r'(?m)^A .*$', s)).most_common(3))
msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
for pat in ('Poster', 'mount3|ngpu|wallpaper'):
    c = Counter(re.sub(r'\[ *[\d.]+\]:?|\[\d+\]|\(\d+\)|\d+', '#', h)[:170] for h in re.findall(r'[ -~]{0,70}(?:%s)[ -~]{0,100}' % pat, msg))
    print('--', pat, sum(c.values()))
    for k, v in c.most_common(10):
        print(f'{v:4d} {k}')
