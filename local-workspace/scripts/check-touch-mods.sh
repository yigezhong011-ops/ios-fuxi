#!/bin/bash
set -uo pipefail
echo "=== 哪些补丁真正修改 bsd/dev/fuxi_touch.c ==="
grep -l -- '--- a/bsd/dev/fuxi_touch.c' /root/ios-fuxi/xnu/patches/*.patch 2>/dev/null | sort
echo
echo "=== 各补丁的 hunk 头（若是修改）==="
for p in $(grep -l -- '--- a/bsd/dev/fuxi_touch.c' /root/ios-fuxi/xnu/patches/*.patch 2>/dev/null); do
  echo "--- $(basename $p)"
  grep -n '^@@' "$p" | head -6
done
