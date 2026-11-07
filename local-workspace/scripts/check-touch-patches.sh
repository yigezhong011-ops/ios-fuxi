#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi/xnu/patches
echo "=== 涉及 fuxi_touch.c 的补丁 ==="
grep -l 'fuxi_touch.c' *.patch | sort
echo
echo "=== 各补丁里的行数（改这个文件的行号上下文）==="
for p in $(grep -l 'fuxi_touch.c' *.patch | sort); do
  echo "--- $p"
  grep -n '^@@' "$p" | head -5
done
