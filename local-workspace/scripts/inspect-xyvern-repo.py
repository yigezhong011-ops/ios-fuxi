#!/usr/bin/env python3
"""Look inside Xyvern08371/unixnu-fuxi (payload artifact + gpu-ci branch) and the
big Status.md of hanzi123-bilp/uefi-fuxi."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, ref, path, limit=4000):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read(limit).decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败 %s)' % e


print('=== Xyvern08371/unixnu-fuxi 顶层 ===')
c = api('https://api.github.com/repos/Xyvern08371/unixnu-fuxi/contents')
if isinstance(c, list):
    for x in c:
        print('   %-28s %-5s %d B' % (x['name'], x['type'], x.get('size', 0)))

print()
print('=== README ===')
print(raw('Xyvern08371/unixnu-fuxi', 'main', 'README.md')[:1500])

print()
print('=== out_fuxi.payload 文件头（API 元数据 + 前 64 字节经 raw）===')
meta = api('https://api.github.com/repos/Xyvern08371/unixnu-fuxi/contents/out_fuxi.payload')
if 'size' in meta:
    print('   size', meta['size'], 'sha', meta['sha'][:12])
try:
    url = 'https://raw.githubusercontent.com/Xyvern08371/unixnu-fuxi/main/out_fuxi.payload'
    req = urllib.request.Request(url, headers={**H, 'Range': 'bytes=0-127'})
    with urllib.request.urlopen(req, timeout=60) as r:
        head = r.read(128)
    print('   前 64 字节:', head[:64].hex())
    print('   ascii:', repr(head[:32]))
except Exception as e:
    print('   读取失败:', e)

print()
print('=== gpu-ci 分支的顶层 ===')
c2 = api('https://api.github.com/repos/Xyvern08371/unixnu-fuxi/contents?ref=gpu-ci')
if isinstance(c2, list):
    for x in c2:
        print('   %-28s %-5s %d B' % (x['name'], x['type'], x.get('size', 0)))
