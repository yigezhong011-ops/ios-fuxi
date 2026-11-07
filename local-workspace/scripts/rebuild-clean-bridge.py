#!/usr/bin/env python3
"""Remove the load probe from the bridge build and rebuild it in the fork."""
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


path = 'tools/mesa-ios/build-bridge.sh'
cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}')
txt = base64.b64decode(cur['content']).decode()
print('原 build-bridge.sh 里的 probe 引用:', 'fuxi_probe.c' in txt)

# 去掉 probe 源文件
new = txt.replace(' "$KIT/userland/fuxi_probe.c"', '').replace('"$KIT/userland/fuxi_probe.c" ', '')
if 'fuxi_probe' in new:
    print('仍有残留，需要手工检查')
else:
    print('已从构建里移除探针')

body = {'message': 'mesa-ios: build the bridge without the load probe',
        'content': base64.b64encode(new.encode()).decode(), 'sha': cur['sha'], 'branch': 'main'}
r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=body)
print('pushed', r['commit']['sha'][:8])

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
target = next(w['id'] for w in wfs['workflows'] if w['path'].endswith('mesa-ios.yml'))
call(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
     data={'ref': 'main', 'inputs': {'winsys': 'fuxi'}})
print('mesa-ios 已触发')
time.sleep(10)
runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=2')
for x in runs['workflow_runs']:
    print('  run', x['id'], x['name'], x['status'])
