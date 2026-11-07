#!/usr/bin/env python3
"""Dispatch the fuxi-specific UEFI workflow and cancel whatever else started."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/hakios-uefi-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


# cancel runs started by the wrong workflow
runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=5')['workflow_runs']
for r in runs:
    if 'active devices' in (r.get('name') or '') and r['status'] in ('queued', 'in_progress'):
        call(f'https://api.github.com/repos/{REPO}/actions/runs/{r["id"]}/cancel', method='POST')
        print('已取消:', r['name'], r['id'])

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
wf = next(w for w in wfs['workflows'] if w['name'] == 'build fuxi uefi')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main'})
print('已触发 build fuxi uefi', wf['id'])
