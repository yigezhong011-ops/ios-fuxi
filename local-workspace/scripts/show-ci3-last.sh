#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== 655-685 行 ==="
sed -n '655,685p' "$L" | cut -c1-200
