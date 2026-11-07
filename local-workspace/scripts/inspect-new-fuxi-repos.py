#!/usr/bin/env python3
"""Inspect the two fuxi repositories updated today: are they format 2 (shared SoC)
and do they carry any prebuilt artifacts?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, ref, path):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo in ('Xyvern08371/unixnu-fuxi', 'MinecraftVM/fuxi-unixnu', 'hanzi123-bilp/uefi-fuxi'):
    info = api(f'https://api.github.com/repos/{repo}')
    if 'error' in info:
        print(repo, '读取失败')
        continue
    branch = info['default_branch']
    print('=== %s  分支 %s  更新 %s' % (repo, branch, info['pushed_at']))
    for b in api(f'https://api.github.com/repos/{repo}/branches'):
        if isinstance(b, dict) and 'name' in b:
            print('   分支:', b['name'])
    board = raw(repo, branch, 'board.toml')
    if board:
        fmt = 'format 2' if 'schema_version' in board else 'format 1'
        soc = 'soc_source' in board
        print('   board.toml: %d 字节, %s, 共享 SoC: %s' % (len(board), fmt, soc))
        for line in board.splitlines():
            low = line.lower()
            if 'adreno' in low or 'gpu' in low or 'soc_source' in low or 'schema' in low:
                print('     ', line.strip()[:110])
    else:
        print('   没有 board.toml')
    # 大文件
    c = api(f'https://api.github.com/repos/{repo}/contents?ref={branch}')
    if isinstance(c, list):
        big = [(x['name'], x.get('size', 0)) for x in c if x['type'] == 'file' and x.get('size', 0) > 100000]
        if big:
            print('   大文件:', big[:6])
    print()
