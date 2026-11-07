#!/bin/bash
# Push the working tree as a fresh single-commit branch: the clone is shallow, so its
# history cannot be pushed.
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/hakios-xnu-kernel || exit 1

echo "=== 树大小 ==="
du -sh . 2>/dev/null
du -sh prebuilt 2>/dev/null

git config user.name dsh
git config user.email dsh@local
git checkout -q --orphan ci-main 2>/dev/null || git checkout -q ci-main
git add -A 2>&1 | tail -3
git commit -qm "HakiOS kernel tree with the Xiaomi 13 (fuxi) device" 2>&1 | tail -2
echo "=== 提交大小 ==="
git count-objects -vH | grep size-pack

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/hakios-fuxi.git"
echo "=== 推送 ==="
git push -q -f ci ci-main:main && echo "已推送" || echo "推送失败"
