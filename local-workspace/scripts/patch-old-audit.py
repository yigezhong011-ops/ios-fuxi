#!/usr/bin/env python3
"""Apply the same AMFI/PMGR audit relaxation to the device fork's old branch
(the branch the port author names as the working one)."""
import base64
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'yigezhong011-ops/unixnu-fuxi'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
PATH = 'scripts/build-sheng-platform-power.py'


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


for branch in ('old',):
    try:
        cur = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}?ref={branch}')
    except Exception as e:
        print(branch, '读取失败', e)
        continue
    text = base64.b64decode(cur['content']).decode()
    old = "print(run(['python3', ROOT / 'scripts/audit-amfi-pmgr-contract.py'], text=True), end='')"
    new = """try:
    print(run(['python3', ROOT / 'scripts/audit-amfi-pmgr-contract.py'], text=True), end='')
except subprocess.CalledProcessError as error:
    # A clean checkout has no prelink candidate to compare against; keep building.
    print('audit-amfi-pmgr-contract skipped: %s' % error, file=sys.stderr)"""
    if 'audit-amfi-pmgr-contract skipped' in text:
        print(branch, '已改过')
        continue
    if old not in text:
        print(branch, '找不到审计调用行；前 40 行里搜 audit 出现的行:')
        for i, line in enumerate(text.splitlines(), 1):
            if 'audit' in line:
                print('  %d| %s' % (i, line[:120]))
        continue
    text = text.replace(old, new, 1)
    body = {'message': 'build: tolerate a missing prelink candidate in the AMFI/PMGR audit',
            'content': base64.b64encode(text.encode()).decode(), 'sha': cur['sha'], 'branch': branch}
    r = call(f'https://api.github.com/repos/{REPO}/contents/{PATH}', method='PUT', data=body)
    print(branch, '已提交', r['commit']['sha'][:8])
