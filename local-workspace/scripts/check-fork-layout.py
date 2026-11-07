#!/usr/bin/env python3
"""Check the fork's branches and root layout to fix the 404."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


info = api(f'https://api.github.com/repos/{REPO}')
print('默认分支:', info.get('default_branch'), ' fork:', info.get('fork'))
branches = api(f'https://api.github.com/repos/{REPO}/branches')
print('分支:', [b['name'] for b in branches] if isinstance(branches, list) else branches)
root = api(f'https://api.github.com/repos/{REPO}/contents?ref=old')
if isinstance(root, list):
    print('old 分支顶层:', [x['name'] for x in root][:16])
else:
    print('root 读取:', root)
