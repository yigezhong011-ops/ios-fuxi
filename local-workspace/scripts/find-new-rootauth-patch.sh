#!/bin/bash
set -uo pipefail
cd /root/fuxi/uni-fork || exit 1
echo "=== 新版里改 bsd_init.c 的补丁 ==="
grep -ln 'bsd_init.c' patches/xnu/*.patch 2>/dev/null | head -12
echo
echo "=== 搜索 rootvp not authenticated 出现在哪个补丁里 ==="
grep -ln 'rootvp not authenticated' patches/xnu/*.patch 2>/dev/null | head -6
echo
echo "=== 该补丁里的相关段落 ==="
f=$(grep -ln 'rootvp not authenticated' patches/xnu/*.patch 2>/dev/null | head -1)
echo "补丁: $f"
[ -n "$f" ] && grep -n -B6 -A10 'rootvp not authenticated' "$f" | head -40 | cut -c1-165
