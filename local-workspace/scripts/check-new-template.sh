#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-fork || exit 1
echo "=== examples/device 里的文件 ==="
git ls-tree -r --name-only HEAD examples/device 2>/dev/null | head -20
echo
echo "=== 打包脚本模板 ==="
git show HEAD:examples/device/package.sh 2>/dev/null | head -30 | cut -c1-150 || \
  for f in $(git ls-tree -r --name-only HEAD examples/device | grep -i 'pack\|action'); do
    echo "--- $f ---"; git show "HEAD:$f" | head -20 | cut -c1-150
  done
