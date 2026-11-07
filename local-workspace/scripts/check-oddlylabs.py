#!/usr/bin/env python3
"""Inspect OddlyLabs' fuxi device repository and UniXNU fork."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path, ref='main'):
    try:
        url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo in ('OddlyLabs/unixnu-fuxi', 'OddlyLabs/UniXNU'):
    info = api(f'https://api.github.com/repos/{repo}')
    print('===', repo, '| fork:', info.get('fork'), '| pushed:', info.get('pushed_at'))
    files = api(f'https://api.github.com/repos/{repo}/contents')
    if isinstance(files, list):
        print('  顶层:', [f['name'] for f in files][:18])
    board = raw(repo, 'board.toml')
    if board:
        print('  board.toml 前 18 行:')
        for line in board.splitlines()[:18]:
            print('    ', line[:120])
    if repo.endswith('UniXNU'):
        comp = raw(repo, 'components.toml')
        if comp:
            hits = [l for l in comp.splitlines() if 'fuxi' in l.lower() or 'Fts' in l]
            print('  components.toml 里 fuxi/Fts 相关:', hits[:6])
