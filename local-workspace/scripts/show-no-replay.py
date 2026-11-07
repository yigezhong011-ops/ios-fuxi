#!/usr/bin/env python3
"""How does a newer UniXNU write TurnipReplay.h when the replay is skipped?"""
import urllib.request

H = {'User-Agent': 'dsh'}


def raw(ref, path):
    try:
        url = f'https://raw.githubusercontent.com/UniXNU/UniXNU/{ref}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return '(失败: %s)' % e


for ref in ('main',):
    text = raw(ref, 'scripts/build-adreno-metal-plugin.py')
    print('=== %s build-adreno-metal-plugin.py（%d 行）===' % (ref, len(text.splitlines())))
    for i, line in enumerate(text.splitlines(), 1):
        if 'no-replay' in line or 'no_replay' in line or 'TurnipReplay' in line or 'gen-turnip-replay' in line:
            lo = max(0, i - 3)
            hi = min(len(text.splitlines()), i + 6)
            print('--- 第 %d 行附近 ---' % i)
            for j in range(lo, hi):
                print('%4d| %s' % (j + 1, text.splitlines()[j][:170]))
            print()
