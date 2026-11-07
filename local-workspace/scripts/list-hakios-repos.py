#!/usr/bin/env python3
"""List oosexgang's repositories to find the HakiOS main repository name."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


repos = api('https://api.github.com/users/oosexgang/repos?per_page=100&sort=updated')
if isinstance(repos, list):
    print('仓库数', len(repos))
    for r in repos[:25]:
        print('  %-32s %8d KB  %s  %s' % (r['name'], r['size'], r['default_branch'], r['pushed_at'][:10]))
else:
    print(repos)
