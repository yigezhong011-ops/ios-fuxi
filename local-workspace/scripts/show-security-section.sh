#!/bin/bash
set -uo pipefail
D=/root/fuxi/uni-fork/docs
echo "=== security.md 第 30-90 行 ==="
awk 'NR>=30 && NR<=90 {printf "%3d| %s\n", NR, $0}' "$D/concepts/security.md" | cut -c1-170
