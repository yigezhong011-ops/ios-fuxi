#!/usr/bin/env python3
"""Find what the documents say about USB, and read the wallpaper lane document."""
import json
import re
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path):
    url = f'https://raw.githubusercontent.com/{REPO}/main/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/main?recursive=1')
docs = sorted(t['path'] for t in tree.get('tree', [])
              if t['type'] == 'blob' and t['path'].endswith('.md'))

print('=== 文档里提到 USB 的行 ===')
for path in docs:
    text = raw(path)
    hits = [l for l in text.splitlines() if re.search(r'\bUSB\b', l)]
    if hits:
        print('\n--- %s（%d 行）---' % (path, len(hits)))
        for line in hits[:8]:
            print('   ', line.strip()[:170])
