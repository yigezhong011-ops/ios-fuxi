#!/usr/bin/env python3
"""Re-enable Actions on the fork and dispatch a build."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/UniXNU'
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
    print('已启用 Actions')
except Exception as e:
    print('启用失败:', e)

info = call(f'https://api.github.com/repos/{REPO}')
print('archived:', info.get('archived'), 'disabled:', info.get('disabled'), 'fork:', info.get('fork'))
perm = call(f'https://api.github.com/repos/{REPO}/actions/permissions')
print('actions permissions:', perm)
