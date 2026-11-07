#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/bootstrap.sh
echo "=== bootstrap.sh 里 unifdef 相关 ==="
grep -n -B2 -A12 'unifdef' "$B" | head -40
