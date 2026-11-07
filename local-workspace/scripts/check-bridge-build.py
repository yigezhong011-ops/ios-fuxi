#!/usr/bin/env python3
"""Find the bridge build command and its targets at this revision."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


def raw(path):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{REF}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return '(失败: %s)' % e


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{REF}?recursive=1')
files = sorted(t['path'] for t in tree.get('tree', []) if t['type'] == 'blob')
print('scripts 里和 bridge 有关的:')
for f in files:
    if 'bridge' in f and f.startswith('scripts/'):
        print('  ', f)

text = raw('scripts/build-adreno-metal-bridge.py')
print('\n=== build-adreno-metal-bridge.py 前 40 行 ===')
for i, line in enumerate(text.splitlines()[:40], 1):
    print('%4d| %s' % (i, line[:150]))
