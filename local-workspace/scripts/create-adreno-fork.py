#!/usr/bin/env python3
"""Create the fork through the API, then push the fixed driver to it."""
import json
import pathlib
import subprocess
import time
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
UPSTREAM = 'ljhhkx529/NativeAdreno-fuxi'
OURS = 'yigezhong011-ops/NativeAdreno-fuxi'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


try:
    call(f'https://api.github.com/repos/{OURS}')
    print('fork 已存在')
except Exception:
    print('创建 fork…')
    call(f'https://api.github.com/repos/{UPSTREAM}/forks', method='POST', data={'default_branch_only': True})
    for _ in range(30):
        time.sleep(3)
        try:
            call(f'https://api.github.com/repos/{OURS}')
            print('fork 就绪')
            break
        except Exception:
            continue

W = '/root/fuxi/drv-fork'
r = subprocess.run(['git', '-C', W, 'push', '-q', '--force', 'origin', 'HEAD:main'],
                   capture_output=True, text=True)
print('推送:', '成功' if r.returncode == 0 else (r.stderr or '')[:200])
sha = subprocess.run(['git', '-C', W, 'rev-parse', 'HEAD'], capture_output=True, text=True).stdout.strip()
print('提交:', sha)
