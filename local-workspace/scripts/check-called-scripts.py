#!/usr/bin/env python3
"""Which of the scripts check-turnip-darwin-host.py calls exist at this revision?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REF = '793d6bddf7ea90678e3a61e2b2bd4350e5fdce16'
REPO = 'UniXNU/UniXNU'


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{REF}?recursive=1')
files = {t['path'] for t in tree.get('tree', []) if t['type'] == 'blob'}
for want in ('scripts/check-turnip-pipeline-cache-host.py',
             'scripts/check-quartzcore-turnip-cache-host.py',
             'scripts/check-priming-cache-host.py',
             'scripts/gen-turnip-replay.py'):
    print('%-52s %s' % (want, '有' if want in files else '缺'))

print('\n含 quartzcore / priming 的文件:')
for f in sorted(files):
    if 'quartzcore' in f or 'priming' in f:
        print('  ', f)
