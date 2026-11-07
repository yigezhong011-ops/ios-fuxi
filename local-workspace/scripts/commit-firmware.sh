#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git fetch -q origin old
echo "=== build/firmware 是否被跟踪 ==="
git ls-files build/firmware | head -5
echo "=== 磁盘上 ==="
find build/firmware -type f 2>/dev/null | head -5
git add -f build/firmware
git -c user.name=dsh -c user.email=dsh@local commit -q -m "build: ship the three fuxi GPU firmware blobs" || echo "（无改动）"
git push -q origin old && echo "已推送"
git ls-files build/firmware | wc -l
