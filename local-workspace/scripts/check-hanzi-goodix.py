#!/usr/bin/env python3
"""Do the hanzi123-bilp repositories carry a Goodix touch driver?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


repos = api('https://api.github.com/users/hanzi123-bilp/repos?per_page=50&sort=updated')
if isinstance(repos, list):
    for r in repos[:12]:
        print('%-34s %s  %s' % (r['name'], r['default_branch'], r['pushed_at'][:10]))

print()
for repo, branch in (('hanzi123-bilp/unixnu-fuxi', 'main'),):
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/{branch}?recursive=1')
    if 'tree' in tree:
        names = [t['path'] for t in tree['tree']]
        hits = [n for n in names if any(k in n.lower() for k in ('goodix', 'touch', 'novatek'))]
        print(repo, '触控相关文件:', len(hits))
        for n in hits[:15]:
            print('   ', n)
