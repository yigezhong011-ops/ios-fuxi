#!/bin/bash
# Bring our UniXNU fork up to the current upstream, keeping only the workflow
# change that uploads the payload.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/uni-fork
rm -rf "$W"
git clone -q "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/UniXNU.git" "$W"
cd "$W"
git remote add upstream https://github.com/UniXNU/UniXNU.git
git fetch -q upstream main
echo "=== 我们的旧 HEAD ==="
git log --oneline -1 origin/main | cut -c1-100
echo "=== 上游 HEAD ==="
git log --oneline -1 upstream/main | cut -c1-100
git reset -q --hard upstream/main
echo "=== 已同步到上游 ==="
git log --oneline -1 | cut -c1-100

echo "=== 重新加 payload 上传步骤 ==="
python3 - <<'PY'
from pathlib import Path
p = Path('.github/workflows/macos.yml')
t = p.read_text()
anchor = '      - name: Upload the built kernel'
if 'Upload the built payload' in t:
    print('已存在')
elif anchor not in t:
    print('找不到上传内核那一步，跳过')
else:
    insert = '''      - name: Upload the built payload
        if: always() && (contains(inputs.steps, 'payload') || inputs.steps == '')
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-fuxi-payload
          path: |
            out/*/payload/payload.img
          if-no-files-found: warn
          retention-days: 7

'''
    p.write_text(t.replace(anchor, insert + anchor, 1))
    print('已加入 payload 上传')
PY

git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "ci: upload the built payload" 2>/dev/null || echo "（无改动）"
git push -f -q origin main
echo "已推送到 fork"
git log --oneline -2 | cut -c1-100
