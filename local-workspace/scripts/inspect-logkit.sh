#!/bin/bash
set -uo pipefail
echo "=== log kit 结构 ==="
find /root/build/log-kit -maxdepth 2 -type d 2>/dev/null | head -12
echo
echo "=== log kit 里的 .inf ==="
find /root/build/log-kit -name '*.inf' 2>/dev/null | head -10
echo
echo "=== tree/package/UniXNUPkg 里有什么 ==="
ls /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg 2>/dev/null
echo "--- Library ---"
ls /root/build/unixnu/out/fuxi/tree/package/UniXNUPkg/Library 2>/dev/null | head -10
echo
echo "=== 源码 package/UniXNUPkg ==="
ls /root/build/unixnu/package/UniXNUPkg 2>/dev/null
echo "--- Library ---"
ls /root/build/unixnu/package/UniXNUPkg/Library 2>/dev/null | head -10
