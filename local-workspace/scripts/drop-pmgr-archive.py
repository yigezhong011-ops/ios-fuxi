#!/usr/bin/env python3
"""Skip the PMGR archive in our device fork: it is the only one that needs a
prelink candidate, and the kernel only needs its symbol to link (our stub
provides it). Everything after it -- including the Adreno archives -- then
builds, so a GPU-capable kernel can come out of a clean checkout."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


def put(path, text, message, branch='old'):
    cur = call(f'https://api.github.com/repos/{REPO}/contents/{path}?ref={branch}')
    body = {'message': message, 'content': base64.b64encode(text.encode()).decode(),
            'sha': cur['sha'], 'branch': branch}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{path}', method='PUT', data=body)
    print('  ', path, '->', r['commit']['sha'][:8])


# 1) board.toml：去掉 PMGR 归档
cur = call(f'https://api.github.com/repos/{REPO}/contents/board.toml?ref=old')
board = base64.b64decode(cur['content']).decode()
line = '"build-sheng-platform-power.py",'
if line not in board:
    print('board.toml 里已经没有 PMGR 归档')
else:
    board = board.replace('  ' + line + '\n', '', 1)
    put('board.toml', board,
        'board: drop the PMGR archive, the only one that needs a prelink candidate')
    print('   已移除', line)

# 2) 新的 defconfig：full 的副本 + stub 归档
full = call(f'https://api.github.com/repos/{REPO}/contents/configs/fuxi_full_defconfig?ref=old')
text = base64.b64decode(full['content']).decode()
extra = ('\n# Link-only stubs for the symbols the skipped archive provided.\n'
         'CONFIG_XNU_EXTRA_LD_ARCHIVES="../../../device/build/fuxi-link-stubs/libFuxiLinkStubs.a"\n')
if 'CONFIG_XNU_EXTRA_LD_ARCHIVES' in text:
    text = '\n'.join(l for l in text.splitlines() if not l.startswith('CONFIG_XNU_EXTRA_LD_ARCHIVES')) + extra
else:
    text = text + extra
put('configs/fuxi_gpu_defconfig', text,
    'configs: full configuration plus the link stubs, without the PMGR archive')
print('   新配置 fuxi_gpu_defconfig 行数:', len(text.splitlines()))
