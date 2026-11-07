#!/usr/bin/env python3
"""Show which step failed in the newest run and the tail of that step's log."""
import io
import json
import pathlib
import urllib.request
import zipfile

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

runs = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=1', headers=H), timeout=60))
run = runs['workflow_runs'][0]
jobs = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/jobs', headers=H), timeout=60))
failed = []
for j in jobs['jobs']:
    print('job', j['name'], j.get('conclusion'))
    for s in j['steps']:
        if s.get('conclusion') == 'failure':
            failed.append(s['name'])
            print('   FAILED step:', s['name'])

data = urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{REPO}/actions/runs/{run["id"]}/logs', headers=H), timeout=180).read()
zf = zipfile.ZipFile(io.BytesIO(data))
for n in zf.namelist():
    if any(f.split(' ')[0] in n for f in failed) or 'Build selected' in n:
        text = zf.read(n).decode('utf-8', 'replace').splitlines()
        print('===', n, '(', len(text), 'lines )')
        for line in text[-25:]:
            print('  ', line[30:][:190])
        break
