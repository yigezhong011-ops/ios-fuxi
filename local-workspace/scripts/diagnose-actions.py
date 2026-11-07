#!/usr/bin/env python3
"""Diagnose why the dispatch is refused: list workflows, their state, and enable."""
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


wfs = call(f'https://api.github.com/repos/{REPO}/actions/workflows')
for w in wfs['workflows']:
    print('%-28s state=%-10s id=%s' % (w['name'][:28], w['state'], w['id']))

for w in wfs['workflows']:
    if 'macos' in w['path']:
        try:
            call(f'https://api.github.com/repos/{REPO}/actions/workflows/{w["id"]}/enable', method='PUT')
            print('已启用 workflow', w['id'])
        except Exception as e:
            print('启用失败', e)

info = call(f'https://api.github.com/repos/{REPO}')
print('default_branch:', info['default_branch'], 'push access:', info.get('permissions'))
