#!/usr/bin/env python3
"""Find a repository that accepts issues so the report can be filed."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

for repo in ('UniXNU/UniXNU', 'ljhhkx529/uefi-fuxi', 'ljhhkx529/unixnu-fuxi',
             'Xyvern08371/unixnu-fuxi', 'hanzi123-bilp/unixnu-fuxi'):
    try:
        info = json.loads(urllib.request.urlopen(
            urllib.request.Request(f'https://api.github.com/repos/{repo}', headers=H), timeout=60).read().decode())
        print('%-32s issues=%s  discussions=%s' % (repo, info.get('has_issues'), info.get('has_discussions')))
    except Exception as e:
        print('%-32s 读取失败 %s' % (repo, e))
