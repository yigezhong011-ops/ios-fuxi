#!/bin/bash
set -uo pipefail
R=/mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm/redwood_drm.c
echo "=== redwood_drm.c：和内核服务对话的方式 ==="
grep -n 'IOService\|IOConnect\|IOConnectCall\|RedwoodGPU\|selector\|kern_return' "$R" | head -20
echo
echo "=== call_with_return 附近 ==="
sed -n '120,175p' "$R"
