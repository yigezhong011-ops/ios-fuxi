#!/bin/bash
set -uo pipefail
W=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/.github/workflows/macos.yml
echo "=== 官方 macos.yml 前 70 行 ==="
sed -n '1,70p' "$W"
