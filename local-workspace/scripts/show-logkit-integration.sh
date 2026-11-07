#!/bin/bash
set -uo pipefail
echo "=== dec.snippet ==="
cat /root/build/log-kit/integration/UniXNUPkg.dec.snippet 2>/dev/null
echo
echo "=== integration 目录 ==="
ls /root/build/log-kit/integration 2>/dev/null
echo
echo "=== README 的集成段（60-95 行）==="
awk 'NR>=55 && NR<=100 {printf "%3d| %s\n", NR, substr($0,1,140)}' /root/build/log-kit/README.md
