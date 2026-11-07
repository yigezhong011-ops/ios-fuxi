#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== 谁引用了 fuxi-unixnu 源码 ==="
grep -rn 'fuxi-unixnu' tools/*.sh tools/ci/*.sh 2>/dev/null | head -12
echo
echo "=== 是否有把仓库源码拷进 XNU 树的逻辑 ==="
grep -rn 'cp .*fuxi-\|rsync.*fuxi-' tools/*.sh tools/ci/*.sh 2>/dev/null | head -12
echo
echo "=== 补丁里是否有 new file mode（整文件新增）==="
grep -l 'new file mode' xnu/patches/010*.patch | head -5
