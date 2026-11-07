#!/usr/bin/env python3
"""Which submodule commits does the upstream GPU branch pin?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'UniXNU/UniXNU'
SHA = '135b0dabed'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{SHA}?recursive=1')
if 'tree' in tree:
    subs = [t for t in tree['tree'] if t['type'] == 'commit']
    print('子模块 %d 个：' % len(subs))
    for t in subs:
        print('  %-40s %s' % (t['path'][:40], t['sha'][:12]))
        if t['path'] in ('drivers/Adreno740', 'drivers/AdrenoMetal', 'kits/XnuPrelink'):
            info = api(f'https://api.github.com/repos/{REPO}/contents/{t["path"]}?ref=main')
else:
    print(tree)
