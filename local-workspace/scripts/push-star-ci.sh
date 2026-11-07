#!/bin/bash
# Star-mailaz's UniXNU tree handles the stage scripts their device repository needs;
# put it in its own CI repository.
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=unixnu-star
cd /root/fuxi/uni-star || exit 1

echo "=== 树 ==="
git log --oneline -1 | cut -c1-90
grep -c 'Upload the built kernel' .github/workflows/macos.yml 2>/dev/null || echo "0（需要加）"

python3 - <<'PY'
from pathlib import Path
p = Path('.github/workflows/macos.yml')
t = p.read_text()
if 'Upload the built kernel' in t:
    print('已有上传步骤')
else:
    anchor = '      - name: Upload the build logs'
    if anchor not in t:
        raise SystemExit('找不到日志上传')
    insert = '''      - name: Upload the built kernel
        if: always() && steps.kernel.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-${{ steps.check.outputs.board }}-kernel
          path: |
            out/*/*/*/kernel/kernel.macho
            out/*/*/*/kernel/kernel.json
          if-no-files-found: warn
          retention-days: 7

      - name: Upload the built payload
        if: always() && steps.payload.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-${{ steps.check.outputs.board }}-payload
          path: |
            out/*/*/*/payload/payload.img
          if-no-files-found: warn
          retention-days: 7

'''
    p.write_text(t.replace(anchor, insert + anchor, 1))
    print('已加入上传步骤')
PY

git config user.name dsh
git config user.email dsh@local
git add -A
git commit -qm "ci: upload the built kernel and payload" 2>/dev/null || echo "（无改动）"

python3 - "$TOKEN" "$REPO" <<'PY'
import json, sys, urllib.request
token, name = sys.argv[1], sys.argv[2]
H = {'Authorization': f'Bearer {token}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
body = json.dumps({'name': name, 'private': False,
                   'description': 'Star-mailaz UniXNU tree for the iOS 16 fuxi port'}).encode()
req = urllib.request.Request('https://api.github.com/user/repos', data=body, headers=H, method='POST')
try:
    r = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
    print('已建仓库:', r['full_name'])
except urllib.error.HTTPError as e:
    print('建仓库:', e.code, e.read().decode()[:120])
PY

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/${REPO}.git"
git push -q -f ci HEAD:main && echo "已推送" || echo "推送失败"
