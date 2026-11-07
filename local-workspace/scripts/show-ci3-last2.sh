#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 700-735 行 ==="
sed -n '700,735p' "$L" | cut -c1-200
