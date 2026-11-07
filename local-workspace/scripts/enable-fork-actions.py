#!/usr/bin/env python3
"""Enable Actions on the fork, then dispatch."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/ios-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None, quiet=False):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            body = r.read().decode() or '{}'
            return json.loads(body) if body.strip() else {}
    except Exception as e:
        if not quiet:
            print('  !', method, url.split('/repos/')[-1], '->', e)
        return None


print('=== 开启 Actions ===')
r = call(f'https://api.github.com/repos/{REPO}/actions/permissions', method='PUT',
         data={'enabled': True, 'allowed_actions': 'all'})
print('PUT actions/permissions ->', 'ok' if r is not None else 'failed')

print('=== 强制同步一次上游（让 workflow 文件就位）===')
call(f'https://api.github.com/repos/{REPO}/merge-upstream', method='POST', data={'branch': 'main'})
time.sleep(5)

wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
items = (wfs or {}).get('workflows', [])
print('工作流:', len(items))
for w in items:
    print(' ', w['id'], w['path'], w['state'])

target = next((w['id'] for w in items if w['path'].endswith('fuxi-build.yml')), None)
if target is None:
    print('仍未看到 fuxi-build.yml，检查文件是否存在:')
    c = call(f'https://api.github.com/repos/{REPO}/contents/.github/workflows')
    for x in (c or []):
        print('  ', x['name'])
else:
    r = call(f'https://api.github.com/repos/{REPO}/actions/workflows/{target}/dispatches', method='POST',
             data={'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                             'mesa': False, 'tools': False}})
    print('触发:', 'ok' if r is not None else 'failed')
    time.sleep(10)
    runs = call(f'https://api.github.com/repos/{REPO}/actions/runs?per_page=3')
    for x in (runs or {}).get('workflow_runs', []):
        print('  run', x['id'], x['name'], x['status'], x.get('conclusion'))
