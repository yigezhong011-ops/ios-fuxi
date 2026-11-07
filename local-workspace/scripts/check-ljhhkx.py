#!/usr/bin/env python3
"""Compare ljhhkx529's old branch with our fork."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
UP = 'ljhhkx529/unixnu-fuxi'
MINE = 'yigezhong011-ops/unixnu-fuxi'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path, ref='old'):
    try:
        url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo in (UP, MINE):
    info = api(f'https://api.github.com/repos/{repo}')
    print('===', repo, '| pushed:', info.get('pushed_at'))
    commits = api(f'https://api.github.com/repos/{repo}/commits?sha=old&per_page=3')
    if isinstance(commits, list):
        for c in commits:
            print('   ', c['sha'][:8], c['commit']['author']['date'][:16], c['commit']['message'].splitlines()[0][:70])

print()
print('=== ljhhkx529 的 board.toml 启动参数 ===')
board = raw(UP, 'board.toml')
if board:
    import re
    m = re.search(r'kernel_args = \[(.*?)\]', board, re.S)
    if m:
        print(m.group(0)[:1200])
