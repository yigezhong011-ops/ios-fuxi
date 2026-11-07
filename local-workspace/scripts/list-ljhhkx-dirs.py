#!/usr/bin/env python3
"""List ljhhkx529's configs and scripts on the old branch."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'ljhhkx529/unixnu-fuxi'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for d in ('configs', 'package', 'scripts', 'patches/xnu'):
    items = api(f'https://api.github.com/repos/{REPO}/contents/{d}?ref=old')
    if isinstance(items, list):
        names = [i['name'] for i in items]
        print('=== %s (%d):' % (d, len(names)))
        print('   ', ', '.join(names[:28]))
    else:
        print('===', d, items)
