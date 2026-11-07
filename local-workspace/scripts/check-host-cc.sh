#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== HOST_COMPAT_CFLAGS / HOST_CC 的定义 ==="
grep -rn 'HOST_COMPAT_CFLAGS\|HOST_CC *[:?]*=' "$T/.cache/xnu-work/makedefs" "$T/.cache/xnu-work/config" 2>/dev/null | head -8 | cut -c1-170
echo
echo "=== xnu-host-cc 内容 ==="
W=$(find /opt/unixnu-linux $HOME/.local/xnu-linux -name 'xnu-host-cc' 2>/dev/null | head -1)
echo "路径: $W"
[ -n "$W" ] && head -25 "$W" | cut -c1-160
