#!/bin/bash
# Push the tree as a single-commit branch (the clone is shallow).
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/uni-odd || exit 1
git config user.name dsh
git config user.email dsh@local
git checkout -q --orphan ci-main 2>/dev/null || git checkout -q ci-main
git add -A 2>&1 | tail -2
git commit -qm "UniXNU fork with the fuxi FTS touch component, plus a kernel workflow" 2>&1 | tail -2
git count-objects -vH | grep size-pack
git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/fuxi-touch-ci.git"
git push -q -f ci ci-main:main && echo "已推送" || echo "推送失败"
