#!/usr/bin/env python3
"""Overview of a GitHub repository: branches with their latest commit, recent commits of a branch,
and files whose path matches a pattern. Read-only.
Usage: gh-repo-overview.py owner/name [branch] [comma-separated path keywords]"""
import json
import pathlib
import re
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120) as r:
        return json.loads(r.read())


repo = sys.argv[1]
api = f'https://api.github.com/repos/{repo}'
info = get(api)
print(repo, '| default', info['default_branch'], '| pushed', info['pushed_at'], '|', info.get('description'))
for b in get(f'{api}/branches?per_page=50'):
    c = get(f"{api}/commits/{b['commit']['sha']}")
    print(f"  branch {b['name']:20} {c['commit']['committer']['date']}  {c['commit']['message'].splitlines()[0][:90]}")
branch = sys.argv[2] if len(sys.argv) > 2 else info['default_branch']
print(f'-- recent commits on {branch}')
for c in get(f'{api}/commits?sha={branch}&per_page=25'):
    print(f"  {c['sha'][:8]} {c['commit']['committer']['date']}  {c['commit']['message'].splitlines()[0][:100]}")
if len(sys.argv) > 3:
    pat = re.compile('|'.join(re.escape(k) for k in sys.argv[3].split(',')), re.I)
    tree = get(f'{api}/git/trees/{branch}?recursive=1')['tree']
    print(f'-- files matching {sys.argv[3]}')
    for t in tree:
        if pat.search(t['path']):
            print('  ', t['type'], t.get('size', ''), t['path'])
