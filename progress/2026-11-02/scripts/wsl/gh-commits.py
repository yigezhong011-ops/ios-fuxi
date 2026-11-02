#!/usr/bin/env python3
"""List recent commits (all branches) of a GitHub repo, with changed files (read-only).
Usage: gh-commits.py <owner/repo> [count] [--files]"""
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def get(url):
    return json.loads(urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=120).read())


repo = sys.argv[1]
count = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 15
files = '--files' in sys.argv
seen = {}
for b in get(f'https://api.github.com/repos/{repo}/branches?per_page=100'):
    for c in get(f'https://api.github.com/repos/{repo}/commits?sha={b["name"]}&per_page={count}'):
        seen.setdefault(c['sha'], (c, set()))[1].add(b['name'])
rows = sorted(seen.values(), key=lambda x: x[0]['commit']['committer']['date'], reverse=True)[:count]
for c, branches in rows:
    msg = c['commit']['message'].splitlines()[0][:110]
    print(f"{c['commit']['committer']['date']} {c['sha'][:10]} [{','.join(sorted(branches))}] {msg}")
    if files:
        for f in get(c['url']).get('files', [])[:40]:
            print(f"      {f['status'][:1]} {f['filename']} +{f['additions']}-{f['deletions']}")
