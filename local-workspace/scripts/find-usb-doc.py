#!/usr/bin/env python3
"""Find the USB document in our repositories."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path, ref='main'):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo in ('yigezhong011-ops/ios-fuxi', 'yigezhong011-ops/fuxi-touch'):
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/main?recursive=1')
    files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
    print('=== %s: %d 个文件 ===' % (repo, len(files)))
    docs = [f for f in files if f.endswith('.md')]
    print('  Markdown %d 个:' % len(docs))
    for f in docs[:25]:
        print('   ', f)
    print('  含 usb 字段名的文件:')
    for f in files:
        if 'usb' in f.lower():
            print('   ', f)
    print()
