#!/usr/bin/env python3
"""List a GitHub user's repositories, newest push first (read-only).
Usage: gh-user-repos.py <user>"""
import json
import pathlib
import sys
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
repos = json.loads(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/users/{sys.argv[1]}/repos?per_page=100&sort=pushed', headers=H), timeout=120).read())
for r in repos:
    print(f"{r['pushed_at']}  {r['name']:32} {'fork' if r['fork'] else '    '}  {(r['description'] or '')[:90]}")
