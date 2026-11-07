#!/usr/bin/env python3
"""Commit the wallpaper workflow and its script to the device repository, then run it."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

files = {
    '.github/workflows/wallpaper.yml': pathlib.Path('/mnt/e/DSH-Fuxi/dump/wsl/wallpaper-workflow.yml').read_text(),
    'ci/make-wallpaper-overlay.py': pathlib.Path('/mnt/e/DSH-Fuxi/read/wallpaper/make-wallpaper-overlay.py').read_text(),
}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


for path, text in files.items():
    try:
        cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}?ref=main')
        sha = cur['sha']
        action = 'updated'
    except urllib.error.HTTPError:
        sha = None
        action = 'created'
    payload = {'message': f'ci: {path} for the wallpaper overlay',
               'content': base64.b64encode(text.encode()).decode(),
               'branch': 'main'}
    if sha:
        payload['sha'] = sha
    r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=payload)
    print('%s %s  %s' % (action, path, r['commit']['sha'][:8]))

time.sleep(15)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
for w in wfs.get('workflows', []):
    print('workflow:', w['name'], w['state'], w['id'])
wf = next((w for w in wfs['workflows'] if w['name'] == 'wallpaper overlay'), None)
if not wf:
    raise SystemExit('workflow 没注册')
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
     method='POST', data={'ref': 'main', 'inputs': {'dmg': '044-76040-038.dmg'}})
print('已触发壁纸构建')
