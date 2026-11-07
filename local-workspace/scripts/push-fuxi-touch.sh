#!/bin/bash
# Unshallow and push the modified device repository.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/fuxi/fuxi-ours
git fetch -q --unshallow 2>/dev/null || git fetch -q --depth 300
git rev-list --count HEAD | tr -d '\n'; echo " 个提交"
git remote remove mine 2>/dev/null || true
git remote add mine "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/fuxi-touch.git"
git push -q -f mine HEAD:main && echo "已推送"
git log --oneline -2 | cut -c1-100
