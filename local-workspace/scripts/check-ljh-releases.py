#!/usr/bin/env python3
"""Does ljhhkx529 publish prebuilt fuxi images (with a USB-capable loader)?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


repos = api('https://api.github.com/users/ljhhkx529/repos?per_page=50&sort=updated')
if isinstance(repos, list):
    print('ljhhkx529 的仓库 %d 个:' % len(repos))
    for r in repos:
        print('  %-30s %-8s 更新 %s' % (r['name'], r['default_branch'], r['pushed_at'][:10]))
else:
    print(repos)

for repo in ('ljhhkx529/unixnu-fuxi', 'ljhhkx529/UniXNU'):
    rel = api(f'https://api.github.com/repos/{repo}/releases')
    if isinstance(rel, list):
        print('\n%s releases: %d' % (repo, len(rel)))
        for r in rel[:3]:
            print('  ', r['tag_name'], [(a['name'], a['size']) for a in r.get('assets', [])][:5])
