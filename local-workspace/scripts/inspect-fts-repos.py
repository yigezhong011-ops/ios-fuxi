#!/usr/bin/env python3
"""Inspect both fuxi touch projects."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for repo in ('OddlyLabs/FuxiFtsTouch', 'yigezhong011-ops/fuxi-touch'):
    info = api(f'https://api.github.com/repos/{repo}')
    print('===', repo, '| 更新', info.get('pushed_at'), '| 大小', info.get('size'), 'KB')
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/{info.get("default_branch", "main")}?recursive=1')
    if 'tree' in tree:
        for t in tree['tree'][:30]:
            if t['type'] == 'blob':
                print('   %8d  %s' % (t.get('size', 0), t['path']))
    else:
        print('   ', tree)
    print()
