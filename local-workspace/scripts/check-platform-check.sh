#!/bin/bash
set -uo pipefail
OURS=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
THEIRS=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/kernel.development.fuxi
for label in "我们的:$OURS" "作者的:$THEIRS"; do
  name=${label%%:*}; k=${label#*:}
  echo "=== $name ==="
  strings -a "$k" | grep -iE 'non-platform|platform binary|platform-binary|unexpected exec' | sort -u | head -6
  echo "  （空 = 没有这个字符串）"
done
