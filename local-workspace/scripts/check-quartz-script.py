#!/usr/bin/env python3
"""Does check-quartzcore-turnip-cache-host.py exist at UniXNU 793d6bddf7, and what does
check-turnip-darwin-host.py do around line 95?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(path):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{REF}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败: %s)' % e


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{REF}?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('该版本 scripts/ 下与 turnip/quartz 有关的：')
for f in files:
    if f.startswith('scripts/') and any(k in f for k in ('turnip', 'quartzcore', 'check-')):
        print('  ', f)

text = raw('scripts/check-turnip-darwin-host.py')
print('\n=== check-turnip-darwin-host.py 80-105 行 ===')
for i, line in enumerate(text.splitlines()[79:105], 80):
    print('%4d| %s' % (i, line[:170]))
