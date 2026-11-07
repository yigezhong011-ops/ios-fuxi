#!/usr/bin/env python3
"""Create a bootstrap defconfig that skips the archive chain entirely, so a
candidate kernel can be linked and prelinked in a clean checkout. The full
build then has the qualified input its audits compare against."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
SRC = 'configs/fuxi_defconfig'
DST = 'configs/fuxi_bootstrap_defconfig'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


cur = call(f'https://api.github.com/repos/{REPO}/contents/{SRC}?ref=old')
text = base64.b64decode(cur['content']).decode()
print('原 defconfig %d 行' % len(text.splitlines()))

out = text.replace('CONFIG_XNU_BUILD_ARCHIVES=y', 'CONFIG_XNU_BUILD_ARCHIVES=n')
header = ("# Bootstrap pass: no archive chain, so the kernel links and prelinks in a\n"
          "# clean checkout and produces the candidate the full build's audits need.\n"
          "# Derived from fuxi_defconfig (stage 2a). Keep the two stubs in\n"
          "# CONFIG_XNU_EXTRA_LD_ARCHIVES: bsd_init references the legacy display probe\n"
          "# unconditionally, and those two symbols only the stubs answer.\n")
out = header + out
print('BUILD_ARCHIVES=n 已写入')

try:
    existing = call(f'https://api.github.com/repos/{REPO}/contents/{DST}?ref=old')
    sha = existing['sha']
    print('已存在，更新')
except Exception:
    sha = None
    print('新建')

body = {'message': 'configs: add a bootstrap defconfig that links without the archive chain',
        'content': base64.b64encode(out.encode()).decode(), 'branch': 'old'}
if sha:
    body['sha'] = sha
r = call(f'https://api.github.com/repos/{REPO}/contents/{DST}', method='PUT', data=body)
print('已提交', r['commit']['sha'][:8])
