#!/usr/bin/env python3
"""List every document in ios-fuxi and find the USB ones."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/main?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
docs = sorted(f for f in files if f.endswith('.md'))
print('全部 %d 个 Markdown:' % len(docs))
for f in docs:
    print('  ', f)
