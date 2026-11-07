#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== build.sh 里 patch 相关 ==="
grep -n 'patch' tools/ci/build.sh | head -20
echo
echo "=== 应用补丁的方式（找 git apply / patch -p1）==="
grep -rn 'git apply\|patch -p1\|patches/' tools/ci/*.sh tools/*.sh 2>/dev/null | head -10
echo
echo "=== 最后一个补丁编号 ==="
ls xnu/patches/ | tail -5
