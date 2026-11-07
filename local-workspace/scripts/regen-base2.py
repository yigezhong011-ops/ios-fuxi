#!/usr/bin/env python3
"""Apply the prerequisite patches' kern_exec.c hunks only, then regenerate 0116."""
import json
import pathlib
import subprocess
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'

work = pathlib.Path('/root/fuxi/regenerate')
target = work / 'bsd/kern/kern_exec.c'
stock = pathlib.Path('/mnt/e/DSH-Fuxi/dump/kern_exec-8796.141.3.c')
target.write_text(stock.read_text())

listing = json.load(urllib.request.urlopen(
    urllib.request.Request(f'https://api.github.com/repos/{REPO}/contents/xnu/patches', headers=H), timeout=60))
names = sorted(x['name'] for x in listing if x['name'].endswith('.patch'))

applied = []
for name in names:
    if name >= '0116':
        continue
    url = f'https://raw.githubusercontent.com/{REPO}/main/xnu/patches/{name}'
    try:
        data = urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'dsh'}), timeout=60).read()
    except Exception:
        continue
    if b'bsd/kern/kern_exec.c' not in data:
        continue
    p = work / 'tmp.patch'
    p.write_bytes(data)
    r = subprocess.run(['git', 'apply', '--include=bsd/kern/kern_exec.c', str(p)],
                       cwd=work, capture_output=True, text=True)
    if r.returncode == 0:
        applied.append(name)
        print('  已应用:', name)
    else:
        print('  失败:', name, r.stderr.strip()[:100])

print('应用列表:', applied)
pathlib.Path('/root/fuxi/regenerate/kern_exec.base.c').write_text(target.read_text())
print('基线已保存')
