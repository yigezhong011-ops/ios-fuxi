#!/usr/bin/env python3
"""List every path of a GitHub repo branch whose name matches a regex (read-only).
Usage: gh-grep-tree.py owner/name branch regex"""
import json
import pathlib
import re
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
repo, branch, pat = sys.argv[1:4]
t = json.loads(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{repo}/git/trees/{branch}?recursive=1', headers=H), timeout=120).read())
rx = re.compile(pat, re.I)
for e in t['tree']:
    if rx.search(e['path']):
        print(e['type'], e.get('size', ''), e['path'])
if t.get('truncated'):
    print('(tree truncated)')
