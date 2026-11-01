#!/usr/bin/env python3
"""Top-level entries (and directory sizes in files) of a GitHub repository branch. Read-only.
Usage: gh-tree.py owner/name [branch]"""
import collections
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
repo = sys.argv[1]
branch = sys.argv[2] if len(sys.argv) > 2 else 'main'
req = urllib.request.Request(f'https://api.github.com/repos/{repo}/git/trees/{branch}?recursive=1', headers=H)
tree = json.loads(urllib.request.urlopen(req, timeout=120).read())['tree']
top = collections.Counter(t['path'].split('/')[0] for t in tree if t['type'] == 'blob')
for name, n in sorted(top.items()):
    print(f'{n:5}  {name}')
