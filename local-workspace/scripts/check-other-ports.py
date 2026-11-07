#!/usr/bin/env python3
"""Check what the other fuxi ports and the docs say about the GPU components and
the accelerator ABI header."""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def raw(repo, ref, path):
    url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
    try:
        return urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30).read().decode('utf-8', 'replace')
    except Exception:
        return ''


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=30) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


REPOS = ['hanzi123-bilp/unixnu-fuxi', 'Xyvern08371/unixnu-fuxi', 'MinecraftVM/fuxi-unixnu',
         'mouse233/unixnu-fuxi', 'kerfand/unixnu-fuxi']

for repo in REPOS:
    info = api(f'https://api.github.com/repos/{repo}')
    if 'error' in info:
        print('%-32s 读取失败' % repo)
        continue
    branch = info['default_branch']
    print('=== %s（%s，更新 %s）' % (repo, branch, info['pushed_at'][:10]))
    board = raw(repo, branch, 'board.toml')
    if board:
        gpu = [l.strip() for l in board.splitlines() if 'adreno' in l.lower() or 'gpu' in l.lower()]
        print('   board.toml 的 GPU 行:', len(gpu))
        for l in gpu[:6]:
            print('     ', l[:130])
        print('   有 NativeMetal 组件:', 'NativeMetal' in board)
    # 查 accelerator 脚本
    acc = raw(repo, branch, 'scripts/build-adreno740-accelerator.py')
    print('   accelerator 脚本:', '有' if acc else '无')
    if acc:
        for line in acc.splitlines():
            if 'OriginalAcceleratorABI' in line or 'AdrenoMetal' in line:
                print('     ', line.strip()[:130])
    print()
