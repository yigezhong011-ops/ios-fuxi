#!/usr/bin/env python3
"""Enable Actions on the HakiOS fork and run the kernel build."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/hakios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


try:
    call(f'https://api.github.com/repos/{REPO}/actions/permissions', method='PUT',
         data={'enabled': True, 'allowed_actions': 'all'})
    print('Actions 已启用')
except Exception as e:
    print('启用:', e)

import time
time.sleep(10)
wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
for w in wfs.get('workflows', []):
    print('workflow:', w['name'], w['state'], w['id'])

wf = next((w for w in wfs.get('workflows', []) if 'fuxi' in w['name']), None)
if not wf:
    raise SystemExit('没找到 build fuxi kernel 工作流')
try:
    call(f'https://api.github.com/repos/{REPO}/actions/workflows/{wf["id"]}/dispatches',
         method='POST', data={'ref': 'main', 'inputs': {'defconfig': 'fuxi_defconfig', 'target': 'kernel'}})
    print('已触发：fuxi_defconfig kernel')
except urllib.error.HTTPError as e:
    print('触发失败', e.code, e.read().decode()[:300])
