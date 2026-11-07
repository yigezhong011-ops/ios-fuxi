#!/usr/bin/env python3
"""Inspect the fuxi touch driver repository."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'OddlyLabs/FuxiFtsTouch'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/main/{path}'
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception:
        return ''


info = api(f'https://api.github.com/repos/{REPO}')
print('repo:', info.get('full_name'), 'pushed:', info.get('pushed_at'), 'desc:', info.get('description'))
files = api(f'https://api.github.com/repos/{REPO}/contents')
if isinstance(files, list):
    print('文件:', [f['name'] for f in files][:20])
readme = raw('README.md')
print('=== README ===')
for line in readme.splitlines()[:40]:
    print('  ', line[:140])
