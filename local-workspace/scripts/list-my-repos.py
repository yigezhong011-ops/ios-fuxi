#!/usr/bin/env python3
"""List our repositories and find the USB-related document."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


repos = api('https://api.github.com/users/yigezhong011-ops/repos?per_page=100&sort=updated')
if isinstance(repos, list):
    print('仓库 %d 个:' % len(repos))
    for r in repos:
        print('  %-28s %s' % (r['name'], r['pushed_at'][:16]))
else:
    print(repos)
