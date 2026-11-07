#!/usr/bin/env python3
"""Print the compiler errors of the most recent kernel run in the new fork."""
import io
import json
import pathlib
import re
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

runs = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1', headers=H), timeout=60))
run = runs['workflow_runs'][0]
print('run', run['id'], run['status'], run.get('conclusion'))

data = urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/logs', headers=H), timeout=180).read()
zf = zipfile.ZipFile(io.BytesIO(data))
for n in zf.namelist():
    if 'Build selected' not in n:
        continue
    text = zf.read(n).decode('utf-8', 'replace')
    seen = set()
    for line in text.splitlines():
        if re.search(r':\d+:\d+: (error|fatal error):', line):
            s = re.sub(r'^\S*T\d\d:\d\d:\d\d\.\d+Z ', '', line.strip())[-200:]
            if s not in seen:
                seen.add(s)
                print(s)
