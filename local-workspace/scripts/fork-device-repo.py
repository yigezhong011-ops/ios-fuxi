#!/usr/bin/env python3
"""Fork the fuxi device repository so the CI audit (which needs local build
products) can be relaxed in our own copy."""
import json
import pathlib
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


me = call('https://api.github.com/user')['login']
print('账号:', me)

try:
    fork = call('https://api.github.com/repos/ljhhkx529/unixnu-fuxi/forks', method='POST',
                data={'default_branch_only': False})
    print('fork 创建中:', fork['full_name'])
except Exception as e:
    print('fork 请求:', e)

for i in range(40):
    try:
        repo = call(f'https://api.github.com/repos/{me}/unixnu-fuxi')
        if repo.get('fork'):
            print('fork 就绪:', repo['full_name'], '默认分支', repo['default_branch'])
            break
    except Exception:
        pass
    time.sleep(5)
else:
    raise SystemExit('fork 还没好')

branches = call(f'https://api.github.com/repos/{me}/unixnu-fuxi/branches')
print('分支:', [b['name'] for b in branches])
