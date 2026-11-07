#!/usr/bin/env python3
"""Build the OddlyLabs fuxi kernel (FTS touch) on our CI."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/fuxi-touch-ci'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


call(f'https://api.github.com/repos/{REPO}/actions/permissions', method='PUT',
     data={'enabled': True, 'allowed_actions': 'all'})
print('Actions 已启用')

time.sleep(12)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
for w in wfs.get('workflows', []):
    print('workflow:', w['name'], w['state'], w['id'])
wf = next((w for w in wfs['workflows'] if 'touch kernel' in w['name']), None)
if not wf:
    raise SystemExit('没找到内核工作流')
try:
    call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
         method='POST', data={'ref': 'main', 'inputs': {
             'defconfig': 'fuxi_defconfig',
             'device_repository': 'yigezhong011-ops/fuxi-touch',
             'device_ref': 'main'}})
    print('已触发：fuxi FTS 触控内核')
except urllib.error.HTTPError as e:
    print('触发失败', e.code, e.read().decode()[:200])
