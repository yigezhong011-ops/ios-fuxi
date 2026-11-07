#!/usr/bin/env python3
"""Fork UniXNU into our account, enable Actions, and show the workflow list."""
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


me = call('https://api.github.com/user')
owner = me['login']
print('账号:', owner)

try:
    fork = call('https://api.github.com/repos/UniXNU/UniXNU/forks', method='POST', data={'default_branch_only': True})
    print('fork 创建中:', fork['full_name'])
except Exception as e:
    print('fork 请求失败（可能已存在）:', e)

for i in range(30):
    try:
        repo = call(f'https://api.github.com/repos/{owner}/UniXNU')
        if repo.get('fork'):
            print('fork 就绪:', repo['full_name'], '默认分支', repo['default_branch'])
            break
    except Exception:
        pass
    time.sleep(5)
else:
    raise SystemExit('fork 还没好')

# 启用 Actions
try:
    call(f'https://api.github.com/repos/{owner}/UniXNU/actions/permissions', method='PUT',
         data={'enabled': True, 'allowed_actions': 'all'})
    print('Actions 已启用')
except Exception as e:
    print('启用 Actions 失败:', e)

wfs = call(f'https://api.github.com/repos/{owner}/UniXNU/actions/workflows')
for w in wfs.get('workflows', []):
    print('  workflow:', w['name'], w['id'], w['path'])
