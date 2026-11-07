#!/usr/bin/env python3
"""Compare the two branches of the fuxi device repository: firmware pins, kernel
args and the archive list may differ, and main may carry a GPU fix."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'ljhhkx529/unixnu-fuxi'


def raw(ref, path):
    url = f'https://raw.githubusercontent.com/{REPO}/{ref}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return ''


for path in ('board.toml', 'scripts/data/fuxi-adreno-inputs.json'):
    a, b = raw('old', path), raw('main', path)
    print('=== %s ===' % path)
    print('  old  %d 字节   main %d 字节  相同: %s' % (len(a), len(b), a == b))
    if a and b and a != b:
        la, lb = a.splitlines(), b.splitlines()
        import difflib
        diff = list(difflib.unified_diff(la, lb, 'old', 'main', lineterm='', n=1))
        for line in diff[:40]:
            print('   ', line[:160])
    print()

print('=== main 的 zap 固件 pin ===')
b = raw('main', 'scripts/data/fuxi-adreno-inputs.json')
if b:
    try:
        d = json.loads(b)
        for k, v in d['firmware']['files'].items():
            print('  %-42s %8s bytes  %s' % (k, v.get('bytes'), v.get('sha256')))
    except Exception as e:
        print('  解析失败:', e)
