#!/usr/bin/env python3
"""GitHub code search (read-only). Usage: gh-code-search.py '<query>'"""
import json
import pathlib
import sys
import urllib.parse
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
q = urllib.parse.quote(sys.argv[1])
r = json.loads(urllib.request.urlopen(urllib.request.Request(
    f'https://api.github.com/search/code?q={q}&per_page=30', headers=H), timeout=120).read())
print('total', r.get('total_count'))
for i in r.get('items', []):
    print(i['repository']['full_name'], i['path'])
