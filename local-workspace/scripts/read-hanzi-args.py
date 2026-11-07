#!/usr/bin/env python3
"""Read hanzi's fuxi board arguments in full: it is the only other port with GPU
switches enabled."""
import urllib.request

H = {'User-Agent': 'dsh'}


def raw(repo, ref, path):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败 %s)' % e


text = raw('hanzi123-bilp/unixnu-fuxi', 'main', 'board.toml')
print('=== hanzi board.toml 里的参数段 ===')
for line in text.splitlines():
    low = line.lower()
    if 'args' in low or 'kernel_args' in low:
        print(line.strip()[:900])
print()
print('=== 归档列表（archives）===')
inside = False
for line in text.splitlines():
    if 'archives' in line:
        inside = True
    if inside:
        print(line.strip()[:140])
        if line.strip().endswith(']'):
            break
