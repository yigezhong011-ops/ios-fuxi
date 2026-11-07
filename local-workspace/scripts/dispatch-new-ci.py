#!/usr/bin/env python3
"""List workflows in the new fork and dispatch the kernel build there."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
OWNER = 'yigezhong011-ops'
REPO = f'{OWNER}/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    return json.load(urllib.request.urlopen(req, timeout=60))


# 等 fork 完成
for i in range(20):
    try:
        r = api(f'https://api.github.com/repos/{REPO}')
        print('fork 就绪, 默认分支', r['default_branch'], ' fork=', r.get('fork'))
        break
    except Exception as e:
        print('等待 fork…', e)
        time.sleep(5)

wfs = api(f'https://api.github.com/repos/{REPO}/actions/workflows')
print('工作流:')
target = None
for w in wfs.get('workflows', []):
    print(' ', w['id'], w['path'], w['state'])
    if w['path'].endswith('fuxi-build.yml'):
        target = w['id']

if target is None:
    raise SystemExit('没找到 fuxi-build.yml')

api(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
    data={'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                    'mesa': False, 'tools': False}})
print('已触发 kernel 构建 (workflow %d)' % target)
time.sleep(10)
runs = api(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3')
for r in runs['workflow_runs']:
    print('  run', r['id'], r['name'], r['status'], r.get('conclusion'))
