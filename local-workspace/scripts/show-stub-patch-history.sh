#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
echo "=== 补丁文件的历史 ==="
git log --oneline --follow -- patches/xnu/fuxi-link-stubs.patch | head -12
echo
echo "=== 各版本的 hunk 头 ==="
for c in $(git log --format=%h --follow -- patches/xnu/fuxi-link-stubs.patch | head -8); do
  printf '%-10s ' "$c"
  git show "$c:patches/xnu/fuxi-link-stubs.patch" 2>/dev/null | grep -m1 '^@@' || echo '（无）'
done
