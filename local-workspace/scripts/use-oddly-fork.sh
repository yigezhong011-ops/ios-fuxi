#!/bin/bash
# Their device repository needs their UniXNU fork, branch fuxi (patches.py handles
# the stage scripts in the series).
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/uni-oddly-fuxi
rm -rf "$W"
git clone -q --branch fuxi https://github.com/OddlyLabs/UniXNU.git "$W" 2>/dev/null || \
  git clone -q https://github.com/OddlyLabs/UniXNU.git "$W"
cd "$W"
git checkout -q fuxi 2>/dev/null || echo "（没有 fuxi 分支，用默认分支）"
echo "=== 分支与版本 ==="
git branch --show-current
git log --oneline -1 | cut -c1-100
echo "=== patches.py 是否处理 .sh stage 脚本 ==="
grep -c 'stage\|\.sh' scripts/unixnu/patches.py 2>/dev/null || echo 0
echo "=== OS profile ==="
ls profiles/os/ 2>/dev/null | head -5

python3 - <<'PY'
from pathlib import Path
p = Path('.github/workflows/macos.yml')
if not p.exists():
    print('没有 workflow')
    raise SystemExit
t = p.read_text()
if 'Upload the built kernel' in t:
    print('已有上传步骤')
else:
    anchor = None
    for cand in ('      - name: Upload the build logs', '      - name: Collect the text logs'):
        if cand in t:
            anchor = cand
            break
    if anchor is None:
        print('找不到日志步骤')
    else:
        insert = '''      - name: Upload the built kernel
        if: always() && steps.kernel.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-fuxi-kernel
          path: |
            out/*/*/*/kernel/kernel.macho
            out/*/*/*/kernel/kernel.json
          if-no-files-found: warn
          retention-days: 7

      - name: Upload the built payload
        if: always() && steps.payload.outcome == 'success'
        uses: actions/upload-artifact@v4
        with:
          name: unixnu-fuxi-payload
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
git push -q -f ci HEAD:main
echo "已推送他们的 fuxi 分支到 unixnu-ci"
