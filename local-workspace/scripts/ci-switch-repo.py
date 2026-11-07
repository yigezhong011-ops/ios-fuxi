#!/usr/bin/env python3
"""Point the CI at another GitHub account's fork.

Usage:
    python3 ci-switch-repo.py            # reads token2.txt, discovers the owner
    python3 ci-switch-repo.py OWNER      # or name it

What it does:
 1. reads E:\\DSH-Fuxi\\token2.txt (the new account's PAT)
 2. checks that the fork exists (creates it from pyhs5g27vr-hue/ios-fuxi if not)
 3. dispatches the kernel build in the fork
Then `ci-download.py` can fetch the artifact with the same token.
"""
import json
import pathlib
import sys
import urllib.request

TOKEN_FILE = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt')
UPSTREAM = 'pyhs5g27vr-hue/ios-fuxi'

if not TOKEN_FILE.is_file():
    raise SystemExit('先创建 %s 并写入新账号的 PAT' % TOKEN_FILE)
TOKEN = TOKEN_FILE.read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    return json.load(urllib.request.urlopen(req, timeout=60))


me = api('https://api.github.com/user')
owner = sys.argv[1] if len(sys.argv) > 1 else me['login']
print('新账号:', me['login'], ' 目标仓库:', f'{owner}/ios-fuxi')

repo = f'{owner}/ios-fuxi'
try:
    api(f'https://api.github.com/repos/{repo}')
    print('仓库已存在')
except Exception:
    print('创建 fork…')
    api(f'https://api.github.com/repos/{UPSTREAM}/forks', method='POST', data={'organization': None} if False else {})
    print('已请求创建 fork，等几秒再试')

# 等 fork 就绪
import time
for _ in range(20):
    try:
        r = api(f'https://api.github.com/repos/{repo}')
        if not r.get('fork') or r['parent']['full_name'] == UPSTREAM:
            break
    except Exception:
        pass
    time.sleep(3)

runs = api(f'https://api.github.com/repos/{repo}/actions/runs?per_page=1')
print('工作流可见:', 'yes' if runs is not None else 'no')
print('仓库默认分支:', api(f'https://api.github.com/repos/{repo}')['default_branch'])

try:
    api(f'https://api.github.com/repos/{repo}/actions/workflows/395549366/dispatches', method='POST',
        data={'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                        'mesa': False, 'tools': False}})
    print('已触发内核构建（旧 workflow id 在新仓库不一定存在，若失败改用下面这条）')
except Exception as e:
    print('旧 id 触发失败:', e)
    wfs = api(f'https://api.github.com/repos/{repo}/actions/workflows')
    for w in wfs['workflows']:
        print('  workflow:', w['id'], w['name'], w['path'])
    for w in wfs['workflows']:
        if w['path'].endswith('fuxi-build.yml'):
            api(f'https://api.github.com/repos/{repo}/actions/workflows/{w["id"]}/dispatches', method='POST',
                data={'ref': 'main', 'inputs': {'kernel': 'metal4', 'metal': False, 'nativemetal': False,
                                                'mesa': False, 'tools': False}})
            print('已用', w['id'], '触发')
            break
