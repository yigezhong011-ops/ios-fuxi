#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon15/boot.log
echo "=== GPU 行数 ==="; grep -a -c 'FUXI GPU' "$L" || true
echo "=== 最后 15 条 ==="
grep -a 'FUXI GPU' "$L" | tail -15
