#!/usr/bin/env python3
"""Point the bootstrap link at the stub archive inside the device repository via a
relative path from the build tree, so the tree rebuild cannot remove it."""
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


cur = call(f'https://api.github.com/repos/{REPO}/contents/configs/fuxi_bootstrap_defconfig?ref=old')
text = base64.b64decode(cur['content']).decode()
old = 'CONFIG_XNU_EXTRA_LD_ARCHIVES="{tree}/build/fuxi-link-stubs/libFuxiLinkStubs.a"'
new = ('# The build tree is <workspace>/out/<device>/tree and the device repository is\n'
       '# <workspace>/<device dir>, so three levels up reaches it. Keeping the archive\n'
       '# there survives the tree rebuilds the driver performs.\n'
       'CONFIG_XNU_EXTRA_LD_ARCHIVES="../../../device/build/fuxi-link-stubs/libFuxiLinkStubs.a"')
if new in text:
    print('已经改过')
else:
    if old not in text:
        raise SystemExit('找不到 EXTRA_LD_ARCHIVES 行')
    text = text.replace(old, new, 1)
    body = {'message': 'configs: take the bootstrap stub archive from the device repository',
            'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': 'old'}
    r = call(f'https://api.github.com/repos/{REPO}/contents/configs/fuxi_bootstrap_defconfig', method='PUT', data=body)
    print('已提交', r['commit']['sha'][:8])

for line in text.splitlines():
    if 'EXTRA_LD' in line or 'BUILD_ARCHIVES' in line or 'BOOT_PROGRESS' in line:
        print('  ', line[:120])
