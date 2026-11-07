#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 600-625 行 ==="
sed -n '600,625p' "$L" | cut -c1-220
