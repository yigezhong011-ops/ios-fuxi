#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/fuxi_adreno_common.py
echo "=== ensure_fuxi_firmware 的实现 ==="
awk '/def ensure_fuxi_firmware/,/^def [a-z_]+\(/' "$F" | head -40
echo
echo "=== 仓库地址常量 ==="
grep -n 'github\|http\|REPO\|URL' "$F" | head -10
