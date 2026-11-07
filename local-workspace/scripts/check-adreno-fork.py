#!/usr/bin/env python3
"""Check what the fuxi Adreno driver fork expects: SMMU stream IDs, GMU register
bases and interrupt numbers."""
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
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60).read().decode('utf-8', 'replace')
    except Exception as e:
        return ''

REPO = 'ljhhkx529/NativeAdreno-fuxi'
info = api(f'https://api.github.com/repos/{REPO}')
print('仓库:', REPO, '->', info.get('default_branch', info.get('error')))
c = api(f'https://api.github.com/repos/{REPO}/contents')
if isinstance(c, list):
    print('顶层:', [x['name'] for x in c][:20])

for path in ('NativeAdrenoGmuPlatform.h', 'NativeAdrenoGmu.cpp', 'README.md'):
    t = raw(REPO, path)
    if not t:
        continue
    print()
    print('=== %s（前 60 行里的关键值）===' % path)
    for i, line in enumerate(t.splitlines()[:80], 1):
        low = line.lower()
        if any(k in low for k in ('0x3d', 'smmu', 'stream', 'irq', 'interrupt', 'gmu', 'fuxi', 'sheng')):
            print('  %3d| %s' % (i, line.strip()[:120]))
