#!/bin/bash
# Like push-old-tree.sh, but to a new branch old-tree of unixnu-ci instead of force-pushing main
# (main currently holds the OddlyLabs fork). Dispatch the macOS workflow with ref old-tree.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
SRC=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
W=/root/fuxi/uni-oldci
BRANCH=old-tree

rm -rf "$W"
git clone -q "$SRC" "$W"
cd "$W"
git remote remove origin 2>/dev/null || true
echo "=== 树版本 ==="
git log --oneline -1 | cut -c1-100

python3 - <<'PY'
from pathlib import Path
p = Path('.github/workflows/macos.yml')
t = p.read_text()
if 'Upload the built kernel' in t:
    print('已有上传步骤')
else:
    anchor = '      - name: Upload the build logs'
    assert anchor in t, '找不到日志上传步骤'
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

git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "ci: upload the built kernel and payload" 2>/dev/null || echo "（无改动）"
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/unixnu-ci.git"
git push -q ci "HEAD:refs/heads/$BRANCH"
echo "已推送旧上游到 unixnu-ci 的 $BRANCH 分支"
git log --oneline -1 | cut -c1-100
