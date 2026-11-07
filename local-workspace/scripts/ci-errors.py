#!/usr/bin/env python3
"""Print only the real compiler errors from the failed kernel log."""
import io
import json
import pathlib
import re
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'
RUN = 40819136564

data = urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/runs/{RUN}/logs', headers=H), timeout=120).read()
zf = zipfile.ZipFile(io.BytesIO(data))
for n in zf.namelist():
    if 'Build selected' not in n:
        continue
    text = zf.read(n).decode('utf-8', 'replace')
    seen = set()
    for line in text.splitlines():
        if re.search(r':\d+:\d+: (error|fatal error):', line):
            s = line.strip()[-200:]
            if s not in seen:
                seen.add(s)
                print(s)
