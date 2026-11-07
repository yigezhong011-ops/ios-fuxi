#!/bin/bash
# Push the HakiOS tree with the fuxi device (force-add: the device dirs are normally
# separate repositories).
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/hakios-xnu-kernel || exit 1

git -c user.name=dsh -c user.email=dsh@local add -f devices/fuxi 2>&1 | tail -2
git -c user.name=dsh -c user.email=dsh@local add -f .github/workflows/build.yml 2>&1 | tail -2
echo "=== 待提交 ==="
git status --short | head -12
git -c user.name=dsh -c user.email=dsh@local commit -qm "fuxi: device repository from its own device tree, plus a macOS build workflow" 2>&1 | tail -2

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/hakios-fuxi.git"
echo "=== 推送 ==="
git push -q -f ci HEAD:main && echo "已推送" || echo "推送失败"
git log --oneline -1 | cut -c1-90
