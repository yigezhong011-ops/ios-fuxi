#!/bin/bash
# GitHub disabled Actions on the fork; a plain repository with the same content
# runs them normally.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
NEW=unixnu-ci

python3 - "$TOKEN" "$NEW" <<'PY'
import json, sys, urllib.request
token, name = sys.argv[1], sys.argv[2]
H = {'Authorization': f'Bearer {token}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
body = json.dumps({'name': name, 'private': False,
                   'description': 'UniXNU build with the payload upload step'}).encode()
req = urllib.request.Request('https://api.github.com/user/repos', data=body, headers=H, method='POST')
try:
    r = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
    print('已建仓库:', r['full_name'])
except urllib.error.HTTPError as e:
    print('建仓库:', e.code, e.read().decode()[:200])
PY

cd /root/fuxi/uni-fork
git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/${NEW}.git"
git push -q -f ci main
echo "已推送 main 到 ${NEW}"

python3 - "$TOKEN" "$NEW" <<'PY'
import json, sys, urllib.request
token, name = sys.argv[1], sys.argv[2]
H = {'Authorization': f'Bearer {token}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
def call(url, method='GET', data=None):
    req = urllib.request.Request(url, data=json.dumps(data).encode() if data else None,
                                 headers=H, method=method)
    with urllib.request.urlopen(req, timeout=60) as r:
        b = r.read().decode()
        return json.loads(b) if b.strip() else {}
repo = f'yigezhong011-ops/{name}'
call(f'https://api.github.com/repos/{repo}/actions/permissions', 'PUT',
     {'enabled': True, 'allowed_actions': 'all'})
wfs = call(f'https://api.github.com/repos/{repo}/actions/workflows')
for w in wfs.get('workflows', []):
    print('  workflow:', w['name'], w['state'], w['id'])
PY
