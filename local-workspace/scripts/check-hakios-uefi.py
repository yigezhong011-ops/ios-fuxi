#!/usr/bin/env python3
"""Which UEFI platforms does hakios-uefi carry?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for path in ('', 'Platforms', 'Platforms/Xiaomi'):
    url = f'https://api.github.com/repos/oosexgang/hakios-uefi/contents/{path}'
    data = api(url)
    if isinstance(data, list):
        print(path or '/', '->', [d['name'] for d in data][:14])
    else:
        print(path or '/', '->', str(data)[:120])

print()
sm = api('https://api.github.com/repos/oosexgang/hakios-sm7325/contents/uefi')
if isinstance(sm, list):
    print('sm7325/uefi ->', [d['name'] for d in sm][:12])
