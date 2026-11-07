#!/usr/bin/env python3
"""Is there an FTS/FocalTech touch driver for UniXNU anywhere?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=40) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


for q in ('ShengFts', 'unixnu fts touch', 'NativeFtsTouch', 'focaltech unixnu'):
    res = api(f'https://api.github.com/search/repositories?q={q.replace(" ", "+")}&per_page=5')
    print('查询 %-24s 结果 %s' % (q, res.get('total_count', res.get('error'))))
    for item in res.get('items', [])[:4]:
        print('   ', item['full_name'], item['pushed_at'][:10])

# also look inside the sheng device repo for a second sensor
tree = api('https://api.github.com/repos/UniXNU/UniXNU-sheng/git/trees/main?recursive=1')
if 'tree' in tree:
    names = [t['path'] for t in tree['tree']]
    hits = [n for n in names if any(k in n.lower() for k in ('fts', 'focal', 'goodix', 'novatek'))]
    print('\nUniXNU-sheng 里触控相关:', hits[:12])
