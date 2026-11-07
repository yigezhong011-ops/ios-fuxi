#!/usr/bin/env python3
"""Which boot wrote twrp-oslog1, did the export run, did migration repeat? Read-only."""
import re
import subprocess
from pathlib import Path

DEC = '/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py'
o = Path('/root/fuxi/log-oslog1')
subprocess.run(['rm', '-rf', str(o)])
subprocess.run(['python3', '-I', DEC, '--decode', '/mnt/e/DSH-Fuxi/logs/twrp-oslog1.bin', '--out', str(o)], capture_output=True)
d = next(o.glob('*/'))
print((d / 'header.txt').read_text()[:900])
text = (d / 'slots.txt').read_text(errors='replace')
slots = [x for x in re.split(r'(?m)^(?=#slot )', text) if x.startswith('#slot')]
print('slots', len(slots))
for i in (0, len(slots) // 2, -1):
    m = re.search(r'^D st=.*$', slots[i], re.M)
    print(slots[i].splitlines()[0], m[0][:110] if m else None)
last = slots[-1]
for line in last.splitlines():
    if re.match(r'(\[coherence|\[gpu clients|\[metal askers|X[0-9] |.*export|.*Export|E[0-9] )', line):
        print(' ', line[:200])
print('files', sorted(x.name for x in d.iterdir()))
msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
for pat in (r'adrenoprobed|oslog|cacheexport|export', r'datamigrator|DataMigrat|migration', r'PosterBoard|PBF', r'WidgetRenderer|chronod|WidgetKit'):
    hits = re.findall(r'[ -~]{0,80}(?:%s)[ -~]{0,120}' % pat, msg)
    print('--', pat, len(hits))
    for h in hits[-5:]:
        print('    ', h[:200])
for f in Path('/root/fuxi/src-adrenometal').glob('**/CacheExport.h'):
    print('src', f)
