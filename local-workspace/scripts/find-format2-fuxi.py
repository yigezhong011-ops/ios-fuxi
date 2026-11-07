#!/usr/bin/env python3
"""Look for a format-2 fuxi device repository."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, ref, path):
    try:
        url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception:
        return ''


res = api('https://api.github.com/search/repositories?q=unixnu-fuxi&per_page=20')
print('仓库搜索结果:', res.get('total_count', res.get('error')))
for item in res.get('items', []):
    repo = item['full_name']
    branch = item['default_branch']
    board = raw(repo, branch, 'board.toml')
    fmt = 'format2' if 'schema_version' in board else ('format1' if board else '?')
    pkg = 'pkg' if '[package]' in board else ''
    print('  %-36s %-10s 更新 %s  %s %s' % (repo, branch, item['pushed_at'][:10], fmt, pkg))
