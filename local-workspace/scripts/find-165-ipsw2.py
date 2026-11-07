#!/usr/bin/env python3
"""Print the 16.5 IPSW URL for iPhone10,3."""
import json
import urllib.request

H = {'User-Agent': 'dsh'}
data = json.loads(urllib.request.urlopen(
    urllib.request.Request('https://api.ipsw.me/v4/device/iPhone10,3?type=ipsw', headers=H),
    timeout=60).read().decode())
for f in data.get('firmwares', []):
    if f.get('version') == '16.5':
        print('build:', f.get('buildid'))
        print('url  :', f.get('url'))
        print('keys :', sorted(f.keys()))
        print('size :', f.get('filesize') or f.get('size'))
