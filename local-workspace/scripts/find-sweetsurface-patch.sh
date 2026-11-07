#!/bin/bash
set -uo pipefail
echo "=== 哪些补丁真正添加/修改 SweetSurface.cpp ==="
for p in /root/ios-fuxi/xnu/patches/*.patch; do
  if grep -q 'b/iokit/Kernel/arm/SweetSurface.cpp\|b/bsd/dev/SweetSurface.cpp\|SweetSurface.cpp' "$p" 2>/dev/null; then
    echo "--- $(basename "$p")"
    grep -m2 'SweetSurface.cpp' "$p"
  fi
done | head -20
