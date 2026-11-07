#!/usr/bin/env python3
"""Print the patch of one commit, optionally only files matching a substring (read-only).
Usage: gh-commit-diff.py <owner/repo> <sha> [filter]"""
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
repo, sha = sys.argv[1:3]
flt = sys.argv[3] if len(sys.argv) > 3 else ''
c = json.loads(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/repos/{repo}/commits/{sha}', headers=H), timeout=120).read())
print(c['commit']['message'])
for f in c.get('files', []):
    if flt in f['filename']:
        print(f"=== {f['filename']}")
        print(f.get('patch', '(no patch)'))
