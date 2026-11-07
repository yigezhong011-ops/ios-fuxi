#!/usr/bin/env python3
"""Recent commits in our repos: is there a USB fix document?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for repo in ('yigezhong011-ops/ios-fuxi', 'yigezhong011-ops/unixnu-fuxi', 'yigezhong011-ops/fuxi-touch'):
    commits = api(f'https://api.github.com/repos/{repo}/commits?per_page=15')
    print('=== %s ===' % repo)
    if isinstance(commits, list):
        for c in commits:
            msg = c['commit']['message'].splitlines()[0][:110]
            print('  %s %s  %s' % (c['sha'][:8], c['commit']['author']['date'][:16], msg))
    else:
        print('  ', commits)
    print()
