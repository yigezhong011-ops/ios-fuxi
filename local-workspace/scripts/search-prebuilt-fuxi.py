#!/usr/bin/env python3
"""Search GitHub for prebuilt fuxi UniXNU artifacts (boot.img / payload.img) or
other people's fuxi ports that may carry binaries."""
import json
import pathlib
import urllib.parse
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def search(kind, q, per_page=8):
    url = f'https://api.github.com/search/{kind}?q={urllib.parse.quote(q)}&per_page={per_page}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


print('=== 仓库搜索 ===')
for q in ('fuxi unixnu', 'unixnu fuxi', 'fuxi ios xnu'):
    res = search('repositories', q)
    if 'error' in res:
        print(q, '失败:', res['error'])
        continue
    print('查询 %-16s 命中 %d' % (q, res.get('total_count', 0)))
    for item in res.get('items', [])[:6]:
        print('   %-42s ★%-4d 更新 %s' % (item['full_name'], item['stargazers_count'], item['pushed_at'][:10]))

print()
print('=== 代码搜索：payload.img / boot.img 相关 ===')
for q in ('fuxi unixnu filename:payload.img', 'fuxi filename:boot.img unixnu'):
    res = search('code', q, per_page=5)
    if 'error' in res or 'items' not in res:
        print(q, '->', res.get('error') or res.get('message', '无结果'))
        continue
    print('查询', q, '命中', res.get('total_count'))
    for item in res['items'][:5]:
        print('   ', item['repository']['full_name'], item['path'])
