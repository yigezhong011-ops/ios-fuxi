#!/usr/bin/env python3
"""Compare the reference sheng board (same SoC, working GPU) with fuxi main:
GPU archives, args and payload structure."""
import json
import re
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def raw(repo, ref, path):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return ''


sheng = raw('UniXNU/UniXNU-sheng', 'main', 'board.toml')
fuxi = raw('ljhhkx529/unixnu-fuxi', 'main', 'board.toml')
print('sheng board.toml %d 字节, fuxi(main) %d 字节' % (len(sheng), len(fuxi)))


def section(text, name):
    m = re.search(r'^\[' + re.escape(name) + r'\](.*?)(?=^\[|\Z)', text, re.M | re.S)
    return m.group(1) if m else ''


for board, label in ((sheng, 'sheng'), (fuxi, 'fuxi(main)')):
    print()
    print('=== %s 的 GPU 相关 archive ===' % label)
    body = section(board, 'kernel')
    for line in body.splitlines():
        if any(k in line.lower() for k in ('adreno', 'gpu', 'metal', 'gmu', 'display')):
            print('   ', line.strip()[:120])

    print('=== %s 的 GPU 启动参数 ===' % label)
    p = section(board, 'payload')
    for line in p.splitlines():
        if 'sheng-gpu' in line or 'sheng-fb' in line or 'sheng-vsync' in line or 'backlight' in line:
            print('   ', line.strip()[:120])

print()
print('=== sheng 的 payload 段（前 30 行）===')
for line in section(sheng, 'payload').splitlines()[:30]:
    print('  ', line[:120])
