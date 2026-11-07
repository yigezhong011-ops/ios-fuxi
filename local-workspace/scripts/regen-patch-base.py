#!/usr/bin/env python3
"""Regenerate patch 0116 against a tree that already has 0100 applied.

0100 (sweet-execswap-gpu-abi-trace) edits kern_exec.c as well, so a patch
generated against the stock file does not apply. This rebuilds the working copy
the same way the CI does, then regenerates the diff.
"""
import json
import pathlib
import subprocess
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

work = pathlib.Path('/root/fuxi/regenerate')
(work / 'bsd/kern').mkdir(parents=True, exist_ok=True)

stock = pathlib.Path('/mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c')
target = work / 'bsd/kern/kern_exec.c'
target.write_text(stock.read_text())

# fetch every patch that touches kern_exec.c, in order, and apply those below 0116
listing = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/contents/xnu/patches', headers=H), timeout=60))
names = sorted(x['name'] for x in listing if x['name'].endswith('.patch'))
print('补丁总数:', len(names))

applied = []
for name in names:
    if name >= '0116':
        continue
    url = f'https://raw.githubusercontent.com/{REPO}/main/xnu/patches/{name}'
    try:
        data = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'dsh'}), timeout=60).read()
    except Exception:
        continue
    if b'kern_exec.c' not in data:
        continue
    p = work / 'tmp.patch'
    p.write_bytes(data)
    r = subprocess.run(['git', 'apply', '--check', str(p)], cwd=work, capture_output=True, text=True)
    if r.returncode != 0:
        print('  跳过（不适用于本地副本）:', name, r.stderr.strip()[:80])
        continue
    subprocess.run(['git', 'apply', str(p)], cwd=work, check=True)
    applied.append(name)
    print('  已应用:', name)

print('应用的补丁:', applied)
(work / 'kern_exec.after-0100.c').write_text(target.read_text())
print('已保存打好前置补丁的文件: /root/fuxi/regenerate/kern_exec.after-0100.c')
