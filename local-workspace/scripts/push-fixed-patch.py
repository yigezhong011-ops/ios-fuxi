#!/usr/bin/env python3
"""Push the fixed 0116 patch to the fork and rebuild."""
import base64
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=90) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


path = 'xnu/patches/0116-kern-exec-inject.patch'
content = pathlib.Path('/root/fuxi/0116-kern-exec-inject.patch').read_bytes()
try:
    cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}')
    sha = cur['sha']
except Exception:
    sha = None

body = {'message': 'xnu: fix the forward declaration of exec_inject_target (block scope is illegal)',
        'content': base64.b64encode(content).decode(), 'branch': 'main'}
if sha:
    body['sha'] = sha
r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=body)
print('pushed', r['commit']['sha'][:8])

# dispatch
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
target = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('fuxi-build.yml'))
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
     data={'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                     'mesa': False, 'tools': False}})
print('dispatched')
time.sleep(12)
runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=2')
for x in runs['workflow_runs']:
    print('  run', x['id'], x['name'], x['status'], x.get('conclusion'))
