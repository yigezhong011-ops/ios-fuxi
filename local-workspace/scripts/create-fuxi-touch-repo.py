#!/usr/bin/env python3
"""Create the fuxi-touch repository on our account."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
body = json.dumps({'name': 'fuxi-touch', 'private': False,
                   'description': 'fuxi (Xiaomi 13) UniXNU device repository with the FTS touch probe'}).encode()
req = urllib.request.Request('https://api.github.com/user/repos', data=body, headers=H, method='POST')
try:
    r = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
    print('已建仓库:', r['full_name'])
except urllib.error.HTTPError as e:
    print('建仓库:', e.code, e.read().decode()[:200])
