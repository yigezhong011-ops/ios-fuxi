#!/usr/bin/env python3
"""Find the failing step of the new fork's kernel run and fetch its log tail."""
import json
import pathlib
import urllib.request
import zipfile
import io
import re

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'
RUN = 40819136564

jobs = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/jobs', headers=H), timeout=60))
for j in jobs['jobs']:
    print(j['name'], j.get('conclusion'))
    for s in j['steps']:
        mark = s.get('conclusion')
        if mark not in ('success', 'skipped', None):
            print('   %s: %s' % (mark, s['name']))

url = f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/logs'
data = urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120).read()
zf = zipfile.ZipFile(io.BytesIO(data))
names = [n for n in zf.namelist() if 'kernel' in n.lower() or 'Build' in n]
print('\n日志文件:', names)
for n in names:
    text = zf.read(n).decode('utf-8', 'replace')
    hits = [l for l in text.splitlines() if re.search(r'error:|fatal error|Error|FAILED|panic', l, re.I)]
    if hits:
        print('===', n)
        for l in hits[-25:]:
            print('  ', l.strip()[:190])
