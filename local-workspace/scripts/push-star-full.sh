#!/bin/bash
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/fuxi/uni-star
echo "=== 补全历史 ==="
git fetch -q --unshallow 2>/dev/null || git fetch -q --depth 200
git rev-list --count HEAD | tr -d '\n'; echo " 个提交"
git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/unixnu-ci.git"
git push -q -f ci HEAD:main && echo "已推送"
git log --oneline -1 | cut -c1-100
