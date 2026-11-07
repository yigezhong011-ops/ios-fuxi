#!/usr/bin/env python3
"""Inspect the format-2 fuxi device repository."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'Star-mailaz/fuxi-ios16-device'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path, ref='main'):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{ref}/{path}'
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception as e:
        return ''

info = api(f'https://api.github.com/repos/{REPO}')
print('repo:', info.get('full_name'), 'pushed', info.get('pushed_at'), 'stars', info.get('stargazers_count'))
print()
root = api(f'https://api.github.com/repos/{REPO}/contents')
if isinstance(root, list):
    print('顶层:', [x['name'] for x in root])
print()
board = raw('board.toml')
print('board.toml 行数:', len(board.splitlines()))
for line in board.splitlines()[:40]:
    print('  ', line[:130])
