#!/usr/bin/env python3
"""Find the URL of the 16.5 (20F66) IPSW for iPhone10,3."""
import json
import urllib.request

H = {'User-Agent': 'dsh'}


def api(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
        return json.loads(r.read().decode())


for product in ('iPhone10,3', 'iPhone10,6'):
    try:
        data = api(f'https://api.ipsw.me/v4/device/{product}?type=ipsw')
    except Exception as e:
        print(product, '查询失败', e)
        continue
    hits = [f for f in data.get('firmwares', []) if f.get('version') == '16.5']
    print(product, '16.5 版本数:', len(hits))
    for f in hits[:3]:
        print('  build', f['buildid'], f['size'] // (1 << 20), 'MB')
        print('  ', f['url'])
