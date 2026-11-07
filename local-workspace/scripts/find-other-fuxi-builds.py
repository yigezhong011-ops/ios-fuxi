#!/usr/bin/env python3
"""Look for prebuilt payloads/binaries in the other fuxi forks."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPOS = [
    ('matejkoo217/UniXNU-fuxi', 'main'),
    ('0721GPT/UniXNU-fuxi', 'main'),
    ('hanzi123-bilp/unixnu-fuxi', 'main'),
]


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for repo, ref in REPOS:
    print('===', repo)
    info = api(f'https://api.github.com/repos/{repo}')
    if 'error' in info:
        print('  读取失败:', info['error'])
        continue
    print('  更新 %s  分支 %s  size %d KB' % (info['pushed_at'], info['default_branch'], info['size']))
    # releases
    rel = api(f'https://api.github.com/repos/{repo}/releases')
    if isinstance(rel, list) and rel:
        for r in rel[:2]:
            print('  release:', r.get('tag_name'), [a['name'] for a in r.get('assets', [])][:4])
    # 找大文件 / 二进制目录
    for path in ('', 'assets', 'package', 'prebuilt', 'payload', 'out'):
        u = f'https://api.github.com/repos/{repo}/contents/{path}' if path else f'https://api.github.com/repos/{repo}/contents'
        c = api(u)
        if isinstance(c, dict):
            continue
        big = [(x['name'], x.get('size', 0)) for x in c if x['type'] == 'file' and x.get('size', 0) > 200000]
        if big:
            print('  %-10s 大文件: %s' % (path or '/', big[:5]))
