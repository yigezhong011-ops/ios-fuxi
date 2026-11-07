#!/bin/bash
set -uo pipefail
X=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/.cache/xnu-work
echo "=== XNU 里的 HOST_CC 定义 ==="
grep -rn 'HOST_CC' "$X/makedefs"/*.cmd "$X/SETUP/config/Makefile" 2>/dev/null | head -10
echo
echo "=== 驱动是否导出 HOST_CC ==="
grep -n 'HOST_CC' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py | head -5
echo
echo "=== 构建树里的 CC / HOST_CC 实际值（从日志推断）==="
grep -n 'xnu-host-cc\|host-clang' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/logs/kernel-bootstrap.log 2>/dev/null | head -5
