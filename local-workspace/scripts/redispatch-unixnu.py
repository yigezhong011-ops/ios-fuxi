#!/usr/bin/env python3
"""Re-dispatch the UniXNU macOS build and report the run id."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['path'].endswith('unixnu-macos.yml'))
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches', method='POST',
     data={'ref': 'main', 'inputs': {'steps': 'kernel payload', 'device_ref': 'old'}})
runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3')['workflow_runs']
for r in runs:
    if r['name'].startswith('UniXNU'):
        print('run %s  %s  created %s' % (r['id'], r['status'], r['created_at']))
