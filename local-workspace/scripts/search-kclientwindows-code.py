#!/usr/bin/env python3
"""Where is kClientWindows defined? Search GitHub code."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh',
     'Accept': 'application/vnd.github.text-match+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for q in ('kClientWindows', 'ClientWindows Adreno', 'kClientWindowCount'):
    res = api(f'https://api.github.com/search/code?q={q.replace(" ", "+")}&per_page=10')
    print('=== %s ===' % q)
    if 'error' in res:
        print('  ', res['error'])
        continue
    print('  总数', res.get('total_count'))
    for item in res.get('items', [])[:8]:
        print('  %-46s %s' % (item['repository']['full_name'], item['path']))
        for m in item.get('text_matches', [])[:2]:
            print('     ', m['fragment'].replace('\n', ' ')[:150])
